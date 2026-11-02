import test from 'node:test';
import assert from 'node:assert/strict';
import { LineSplitter, buildPrompt, modelChoices, parseLine } from '../src/events';

test('parseLine entiende los eventos de supercoder', () => {
  assert.deepEqual(parseLine('{"type":"step_start","part":{}}'), { kind: 'step_start' });
  assert.deepEqual(
    parseLine('{"type":"tool_use","part":{"callID":"1","tool":"read","state":{"status":"completed"}}}'),
    { kind: 'tool', id: '1', tool: 'read', status: 'completed' },
  );
  assert.deepEqual(parseLine('{"type":"text","part":{"text":"a \\"b\\"\\nc"}}'), { kind: 'text', text: 'a "b"\nc' });
  assert.deepEqual(parseLine('{"type":"step_finish","part":{"tokens":{"input":3,"output":4}}}'), {
    kind: 'step_finish',
    input: 3,
    output: 4,
  });
});

test('parseLine ignora basura', () => {
  assert.equal(parseLine('no json'), undefined);
  assert.equal(parseLine('{roto'), undefined);
  assert.equal(parseLine('{"type":"otro"}'), undefined);
});

test('LineSplitter conserva líneas parciales', () => {
  const s = new LineSplitter();
  assert.deepEqual(s.push('a\nb'), ['a']);
  assert.deepEqual(s.push('c\nd\n'), ['bc', 'd']);
  assert.deepEqual(s.flush(), []);
  assert.deepEqual(new LineSplitter().push('x'), []);
});

test('buildPrompt añade el historial reciente', () => {
  const h = [
    { user: 'u1', assistant: 'a1' },
    { user: 'u2', assistant: 'a2' },
  ];
  assert.equal(buildPrompt([], 'hola', 6), 'hola');
  assert.equal(buildPrompt(h, 'hola', 0), 'hola');
  const p = buildPrompt(h, 'hola', 1);
  assert.ok(p.includes('u2') && !p.includes('u1') && p.endsWith('hola'));
});

test('modelChoices une config y ajustes sin duplicados', () => {
  const cfg = '{"model":"a","models":{"a":{"port":1},"b":{"port":2}}}';
  assert.deepEqual(modelChoices(cfg, ['b', 'claude:sonnet']), ['a', 'b', 'claude:sonnet']);
  assert.deepEqual(modelChoices('{roto', ['x']), ['x']);
  assert.deepEqual(modelChoices(undefined, []), []);
});
