(function () {
  const vscode = acquireVsCodeApi();
  const log = document.getElementById('log');
  const input = document.getElementById('input');
  const form = document.getElementById('form');
  const send = document.getElementById('send');
  const stop = document.getElementById('stop');
  const modelBtn = document.getElementById('model');
  const tools = new Map();

  function add(cls, text) {
    const d = document.createElement('div');
    d.className = 'msg ' + cls;
    d.textContent = text; // textContent: nunca HTML de la respuesta
    log.appendChild(d);
    log.scrollTop = log.scrollHeight;
    return d;
  }

  function renderText(text) {
    const d = document.createElement('div');
    d.className = 'msg assistant';
    const parts = text.split('```');
    parts.forEach(function (p, i) {
      if (i % 2 === 1) {
        const pre = document.createElement('pre');
        pre.textContent = p.replace(/^[^\n]*\n/, '');
        d.appendChild(pre);
      } else if (p) {
        d.appendChild(document.createTextNode(p));
      }
    });
    log.appendChild(d);
    log.scrollTop = log.scrollHeight;
  }

  function submit() {
    const text = input.value.trim();
    if (!text || send.disabled) return;
    input.value = '';
    vscode.postMessage({ type: 'send', text: text });
  }

  form.addEventListener('submit', function (e) { e.preventDefault(); submit(); });
  input.addEventListener('keydown', function (e) {
    if (e.key === 'Enter' && !e.shiftKey) { e.preventDefault(); submit(); }
  });
  stop.addEventListener('click', function () { vscode.postMessage({ type: 'stop' }); });
  modelBtn.addEventListener('click', function () { vscode.postMessage({ type: 'pickModel' }); });
  document.getElementById('new').addEventListener('click', function () { vscode.postMessage({ type: 'newChat' }); });

  window.addEventListener('message', function (ev) {
    const m = ev.data;
    if (m.type === 'user') add('user', m.text);
    else if (m.type === 'clear') { log.textContent = ''; tools.clear(); }
    else if (m.type === 'insert') { input.value += m.text; input.focus(); }
    else if (m.type === 'model') modelBtn.textContent = 'modelo: ' + (m.model || 'por defecto');
    else if (m.type === 'busy') {
      send.disabled = m.busy; stop.hidden = !m.busy; input.disabled = m.busy;
      if (!m.busy) input.focus();
    } else if (m.type === 'event') {
      const e = m.event;
      if (e.kind === 'text') renderText(e.text);
      else if (e.kind === 'error') add('error', e.message);
      else if (e.kind === 'tool') {
        let el = tools.get(e.id);
        if (!el) { el = add('tool', e.tool); tools.set(e.id, el); }
        el.className = 'msg tool ' + (e.status === 'completed' ? 'done' : 'running');
      } else if (e.kind === 'step_finish' && (e.input || e.output)) {
        add('meta', 'tokens: ' + e.input + ' entrada / ' + e.output + ' salida');
      }
    }
  });
})();
