import test from 'node:test';
import assert from 'node:assert/strict';
import * as fs from 'fs';
import * as os from 'os';
import * as path from 'path';
import { SuperEvent } from '../src/events';
import { startRun } from '../src/runner';

const bin = path.resolve(__dirname, '../../../out/linux/bin/supercoder');

test('startRun lanza supercoder con claude -p y entrega eventos', { skip: !fs.existsSync(bin) }, async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'sc-'));
  fs.writeFileSync(path.join(dir, 'claude'), '#!/bin/sh\necho "args: $*"\n', { mode: 0o755 });
  process.env.PATH = `${dir}:${process.env.PATH}`;
  const events: SuperEvent[] = [];
  const code = await new Promise<number | null>((resolve) =>
    startRun({
      binary: bin,
      cwd: dir,
      prompt: 'hola',
      model: 'claude:sonnet',
      maxTurns: 3,
      onEvent: (e) => events.push(e),
      onDone: (c) => resolve(c),
    }),
  );
  assert.equal(code, 0);
  assert.deepEqual(events.map((e) => e.kind), ['step_start', 'text', 'step_finish']);
  const text = events.find((e) => e.kind === 'text');
  assert.equal(text && text.kind === 'text' && text.text.startsWith('args: -p --model sonnet --'), true);
});

test('startRun informa si el binario no existe', async () => {
  const events: SuperEvent[] = [];
  await new Promise<void>((resolve) =>
    startRun({
      binary: '/no/existe/supercoder',
      cwd: os.tmpdir(),
      prompt: 'x',
      model: '',
      maxTurns: 1,
      onEvent: (e) => events.push(e),
      onDone: () => resolve(),
    }),
  );
  assert.equal(events[0].kind, 'error');
});

test('startRun interactivo contesta a un permiso y recibe los eventos', { skip: !fs.existsSync(bin) }, async () => {
  const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'sc-'));
  const mock = path.resolve(__dirname, '../../../tests/mock_llm.py');
  const { spawn } = await import('child_process');
  fs.writeFileSync(path.join(dir, 'supercoder.json'), '{"models":{"soso-coder":{"port":7455}}}');
  const marker = path.join(dir, 'marcador');
  fs.writeFileSync(
    path.join(dir, 'guion.json'),
    JSON.stringify({
      steps: [
        { type: 'tool_calls', name: 'bash', arguments: { command: `touch ${marker}` } },
        { type: 'content', text: 'hecho' },
      ],
    }),
  );
  const server2 = spawn('python3', [mock, '7455', path.join(dir, 'guion.json')], { stdio: 'ignore' });
  await new Promise((r) => setTimeout(r, 500));
  const events: SuperEvent[] = [];
  process.env.SUPERCODER_HOME = path.join(dir, 'home');
  try {
    const code = await new Promise<number | null>((resolve) => {
      const run = startRun({
        binary: bin,
        cwd: dir,
        prompt: 'toca',
        model: '',
        maxTurns: 5,
        sessionId: 'vs1',
        interactive: true,
        onEvent: (e) => {
          events.push(e);
          if (e.kind === 'permission') {
            run.reply(e.id, 'once');
          }
        },
        onDone: (c) => resolve(c),
      });
    });
    assert.equal(code, 0);
    assert.ok(events.some((e) => e.kind === 'permission'));
    assert.ok(fs.existsSync(marker), 'el comando permitido debe ejecutarse');
    assert.ok(events.some((e) => e.kind === 'text' && e.text === 'hecho'));
  } finally {
    server2.kill();
  }
});
