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
  assert.equal(text && text.kind === 'text' && text.text, 'args: -p --model sonnet -- hola');
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
