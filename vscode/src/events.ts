// Eventos JSON-lines de `supercoder run --format json`.
export interface Todo {
  content: string;
  status: string;
  priority: string;
}

export type SuperEvent =
  | { kind: 'step_start' }
  | {
      kind: 'tool';
      id: string;
      tool: string;
      status: string;
      input?: Record<string, unknown>;
      output?: string;
      title?: string;
    }
  | { kind: 'text'; text: string }
  | { kind: 'text_delta'; text: string }
  | { kind: 'step_finish'; input: number; output: number }
  | { kind: 'error'; message: string }
  | { kind: 'permission'; id: string; callId: string; tool: string; title: string; input?: Record<string, unknown> }
  | { kind: 'todo'; todos: Todo[] }
  | { kind: 'subagent'; callId: string; event: SuperEvent };

export type PermissionReply = 'once' | 'always' | 'reject';

function isObject(v: unknown): v is Record<string, unknown> {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}

function parseObject(o: any): SuperEvent | undefined {
  const part = o.part ?? {};
  switch (o.type) {
    case 'step_start':
      return { kind: 'step_start' };
    case 'tool_use': {
      const ev: SuperEvent = {
        kind: 'tool',
        id: String(part.callID ?? ''),
        tool: String(part.tool ?? ''),
        status: String(part.state?.status ?? ''),
      };
      if (isObject(part.state?.input)) {
        ev.input = part.state.input;
      }
      const out = part.state?.output ?? part.state?.error;
      if (typeof out === 'string') {
        ev.output = out;
      }
      if (typeof part.state?.title === 'string') {
        ev.title = part.state.title;
      }
      return ev;
    }
    case 'text':
      return { kind: 'text', text: String(part.text ?? '') };
    case 'text_delta':
      return { kind: 'text_delta', text: String(part.text ?? '') };
    case 'step_finish':
      return {
        kind: 'step_finish',
        input: Number(part.tokens?.input ?? 0),
        output: Number(part.tokens?.output ?? 0),
      };
    case 'error':
      // supercoder: error.data.message (como OpenCode); se aceptan también formas antiguas.
      return {
        kind: 'error',
        message: String(o.error?.data?.message ?? o.error?.message ?? part.message ?? part.text ?? o.message ?? ''),
      };
    case 'permission_request': {
      const ev: SuperEvent = {
        kind: 'permission',
        id: String(part.id ?? ''),
        callId: String(part.callID ?? ''),
        tool: String(part.tool ?? ''),
        title: String(part.title ?? ''),
      };
      if (isObject(part.input)) {
        ev.input = part.input;
      }
      return ev;
    }
    case 'todo':
      return {
        kind: 'todo',
        todos: Array.isArray(part.todos)
          ? part.todos.map((t: any) => ({
              content: String(t.content ?? ''),
              status: String(t.status ?? 'pending'),
              priority: String(t.priority ?? 'medium'),
            }))
          : [],
      };
    case 'subagent': {
      const inner = isObject(part.event) ? parseObject(part.event) : undefined;
      return inner ? { kind: 'subagent', callId: String(part.callID ?? ''), event: inner } : undefined;
    }
    default:
      return undefined;
  }
}

export function parseLine(line: string): SuperEvent | undefined {
  const s = line.trim();
  if (!s.startsWith('{')) {
    return undefined;
  }
  let o: any;
  try {
    o = JSON.parse(s);
  } catch {
    return undefined;
  }
  return parseObject(o);
}

/** Respuesta a una petición de permiso, en el formato que lee `supercoder` por stdin. */
export function permissionReplyLine(id: string, reply: PermissionReply): string {
  return JSON.stringify({ type: 'permission_reply', id, reply }) + '\n';
}

/** Argumentos de `supercoder run` para unas opciones (sin el ejecutable). */
export interface ArgOptions {
  prompt: string;
  model: string;
  maxTurns: number;
  sessionId?: string;
  cont?: boolean;
  agent?: string;
  interactive?: boolean;
  yes?: boolean;
  files?: string[];
}

export function buildArgs(o: ArgOptions): string[] {
  const args = ['run', '--format', 'json', '--max-turns', String(o.maxTurns)];
  if (o.model) {
    args.push('--model', o.model);
  }
  if (o.sessionId) {
    args.push('--session', o.sessionId);
  }
  if (o.cont) {
    args.push('--continue');
  }
  if (o.agent) {
    args.push('--agent', o.agent);
  }
  if (o.interactive) {
    args.push('--interactive');
  }
  if (o.yes) {
    args.push('--yes');
  }
  for (const f of o.files ?? []) {
    args.push('--file', f);
  }
  args.push('--', o.prompt);
  return args;
}

/** Trocea stdout en líneas completas conservando el resto parcial. */
export class LineSplitter {
  private rest = '';
  push(chunk: string): string[] {
    const parts = (this.rest + chunk).split('\n');
    this.rest = parts.pop() ?? '';
    return parts;
  }
  flush(): string[] {
    const r = this.rest;
    this.rest = '';
    return r ? [r] : [];
  }
}

export interface Turn {
  user: string;
  assistant: string;
}

/** Prompt con el historial reciente como contexto (supercoder no guarda sesión en el host). */
export function buildPrompt(history: Turn[], prompt: string, keep: number): string {
  const recent = keep > 0 ? history.slice(-keep) : [];
  if (recent.length === 0) {
    return prompt;
  }
  const ctx = recent.map((t) => `Usuario: ${t.user}\nAsistente: ${t.assistant}`).join('\n\n');
  return `Conversación previa:\n${ctx}\n\nNuevo mensaje del usuario:\n${prompt}`;
}

/** Lista de modelos para el selector, sin duplicados, extraídos de supercoder.json + ajustes. */
export function modelChoices(configJson: string | undefined, extra: string[]): string[] {
  const out: string[] = [];
  const add = (m: unknown) => {
    if (typeof m === 'string' && m && !out.includes(m)) {
      out.push(m);
    }
  };
  if (configJson) {
    try {
      const cfg = JSON.parse(configJson);
      add(cfg.model);
      Object.keys(cfg.models ?? {}).forEach(add);
    } catch {
      /* supercoder.json inválido: se ignora */
    }
  }
  extra.forEach(add);
  return out;
}

/** Versión del modelo para el selector: `true` si acepta imágenes (visión propia o "vision_model"). */
export function modelAcceptsImages(configJson: string | undefined, model: string): boolean {
  if (!configJson) {
    return false;
  }
  try {
    const cfg = JSON.parse(configJson);
    if (typeof cfg.vision_model === 'string' && cfg.vision_model) {
      return true;
    }
    const name = model || cfg.model || 'soso-coder';
    return cfg.models?.[name]?.vision === true;
  } catch {
    return false;
  }
}
