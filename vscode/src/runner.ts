import { ChildProcess, spawn } from 'child_process';
import { LineSplitter, SuperEvent, parseLine } from './events';

export interface RunOptions {
  binary: string;
  cwd: string;
  prompt: string;
  model: string;
  maxTurns: number;
  onEvent: (e: SuperEvent) => void;
  onDone: (code: number | null, stderr: string) => void;
}

export interface Run {
  stop(): void;
}

export function startRun(o: RunOptions): Run {
  const args = ['run', '--format', 'json', '--max-turns', String(o.maxTurns)];
  if (o.model) {
    args.push('--model', o.model);
  }
  args.push(o.prompt);

  let child: ChildProcess;
  try {
    child = spawn(o.binary, args, { cwd: o.cwd, stdio: ['ignore', 'pipe', 'pipe'] });
  } catch (e) {
    o.onEvent({ kind: 'error', message: String(e) });
    o.onDone(null, '');
    return { stop() {} };
  }

  const split = new LineSplitter();
  let stderr = '';
  const emit = (line: string) => {
    const ev = parseLine(line);
    if (ev) {
      o.onEvent(ev);
    }
  };
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
  };
}
