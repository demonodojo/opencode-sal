import { ChildProcess, spawn } from 'child_process';
import {
  ArgOptions,
  LineSplitter,
  PermissionReply,
  SuperEvent,
  buildArgs,
  parseLine,
  permissionReplyLine,
} from './events';

export interface RunOptions extends ArgOptions {
  binary: string;
  cwd: string;
  onEvent: (e: SuperEvent) => void;
  onDone: (code: number | null, stderr: string) => void;
}

export interface Run {
  stop(): void;
  /** Contesta a una petición de permiso (solo con `interactive`). */
  reply(id: string, reply: PermissionReply): void;
}

export function startRun(o: RunOptions): Run {
  const args = buildArgs(o);
  let child: ChildProcess;
  try {
    child = spawn(o.binary, args, { cwd: o.cwd, stdio: ['pipe', 'pipe', 'pipe'] });
  } catch (e) {
    o.onEvent({ kind: 'error', message: String(e) });
    o.onDone(null, '');
    return { stop() {}, reply() {} };
  }

  const split = new LineSplitter();
  let stderr = '';
  const emit = (line: string) => {
    const ev = parseLine(line);
    if (ev) {
      o.onEvent(ev);
    }
  };
  child.stdin?.on('error', () => {
    /* el proceso terminó antes de leer la respuesta */
  });
  if (!o.interactive) {
    child.stdin?.end();
  }
  child.stdout?.setEncoding('utf8');
  child.stdout?.on('data', (d: string) => split.push(d).forEach(emit));
  child.stderr?.setEncoding('utf8');
  child.stderr?.on('data', (d: string) => (stderr += d));
  child.on('error', (err) => {
    o.onEvent({ kind: 'error', message: `No se pudo lanzar '${o.binary}': ${err.message}` });
    o.onDone(null, stderr);
  });
  child.on('close', (code) => {
    split.flush().forEach(emit);
    o.onDone(code, stderr);
  });

  return {
    stop() {
      child.kill('SIGTERM');
    },
    reply(id: string, reply: PermissionReply) {
      child.stdin?.write(permissionReplyLine(id, reply));
    },
  };
}
