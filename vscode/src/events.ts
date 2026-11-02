// Eventos JSON-lines de `supercoder run --format json`.
export type SuperEvent =
  | { kind: 'step_start' }
  | { kind: 'tool'; id: string; tool: string; status: string }
  | { kind: 'text'; text: string }
  | { kind: 'step_finish'; input: number; output: number }
  | { kind: 'error'; message: string };

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
  const part = o.part ?? {};
  switch (o.type) {
    case 'step_start':
      return { kind: 'step_start' };
    case 'tool_use':
      return {
        kind: 'tool',
        id: String(part.callID ?? ''),
        tool: String(part.tool ?? ''),
        status: String(part.state?.status ?? ''),
      };
    case 'text':
      return { kind: 'text', text: String(part.text ?? '') };
    case 'step_finish':
      return {
        kind: 'step_finish',
        input: Number(part.tokens?.input ?? 0),
        output: Number(part.tokens?.output ?? 0),
      };
    case 'error':
      return { kind: 'error', message: String(part.message ?? part.text ?? o.message ?? '') };
    default:
      return undefined;
  }
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
