import test from 'node:test';
import assert from 'node:assert/strict';
import {
  LineSplitter,
  buildArgs,
  buildPrompt,
  modelAcceptsImages,
  modelChoices,
  parseLine,
  permissionReplyLine,
} from '../src/events';

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

test('parseLine lee el estado completo de una herramienta', () => {
  const ev = parseLine(
    '{"type":"tool_use","part":{"callID":"c","tool":"edit","state":{"status":"completed","input":{"filePath":"a"},"output":"ok","title":"a"}}}',
  );
  assert.deepEqual(ev, { kind: 'tool', id: 'c', tool: 'edit', status: 'completed', input: { filePath: 'a' }, output: 'ok', title: 'a' });
  const bad = parseLine('{"type":"tool_use","part":{"callID":"c","tool":"edit","state":{"status":"error","input":{},"error":"no match"}}}');
  assert.deepEqual(bad, { kind: 'tool', id: 'c', tool: 'edit', status: 'error', input: {}, output: 'no match' });
});

test('parseLine lee error.data.message, permisos, todos y subagentes', () => {
  assert.deepEqual(parseLine('{"type":"error","error":{"name":"Error","data":{"message":"boom"}}}'), { kind: 'error', message: 'boom' });
  assert.deepEqual(
    parseLine('{"type":"permission_request","part":{"id":"perm_1","callID":"call_2","tool":"bash","title":"bash: make","input":{"command":"make"}}}'),
    { kind: 'permission', id: 'perm_1', callId: 'call_2', tool: 'bash', title: 'bash: make', input: { command: 'make' } },
  );
  assert.deepEqual(parseLine('{"type":"todo","part":{"todos":[{"content":"a","status":"pending","priority":"high"}]}}'), {
    kind: 'todo',
    todos: [{ content: 'a', status: 'pending', priority: 'high' }],
  });
  assert.deepEqual(parseLine('{"type":"subagent","part":{"callID":"c1","event":{"type":"text","part":{"text":"hola"}}}}'), {
    kind: 'subagent',
    callId: 'c1',
    event: { kind: 'text', text: 'hola' },
  });
  assert.equal(parseLine('{"type":"subagent","part":{"callID":"c1"}}'), undefined);
  assert.deepEqual(parseLine('{"type":"text_delta","part":{"text":"ab"}}'), { kind: 'text_delta', text: 'ab' });
});

test('permissionReplyLine y buildArgs', () => {
  assert.equal(permissionReplyLine('perm_1', 'always'), '{"type":"permission_reply","id":"perm_1","reply":"always"}\n');
  assert.deepEqual(buildArgs({ prompt: '-x', model: '', maxTurns: 5 }), ['run', '--format', 'json', '--max-turns', '5', '--', '-x']);
  assert.deepEqual(
    buildArgs({ prompt: 'p', model: 'm', maxTurns: 2, sessionId: 's', cont: true, agent: 'plan', interactive: true, files: ['a.png', 'b.txt'] }),
    ['run', '--format', 'json', '--max-turns', '2', '--model', 'm', '--session', 's', '--continue', '--agent', 'plan', '--interactive', '--file', 'a.png', '--file', 'b.txt', '--', 'p'],
  );
  assert.ok(buildArgs({ prompt: 'p', model: '', maxTurns: 1, yes: true }).includes('--yes'));
});

test('modelAcceptsImages usa vision del modelo o vision_model', () => {
  const cfg = '{"model":"a","models":{"a":{"vision":true},"b":{}}}';
  assert.equal(modelAcceptsImages(cfg, ''), true);
  assert.equal(modelAcceptsImages(cfg, 'b'), false);
  assert.equal(modelAcceptsImages('{"vision_model":"v","models":{"b":{}}}', 'b'), true);
  assert.equal(modelAcceptsImages(undefined, 'a'), false);
  assert.equal(modelAcceptsImages('{roto', 'a'), false);
});
