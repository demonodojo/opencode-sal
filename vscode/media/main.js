(function () {
  const vscode = acquireVsCodeApi();
  const log = document.getElementById('log');
  const input = document.getElementById('input');
  const form = document.getElementById('form');
  const send = document.getElementById('send');
  const stop = document.getElementById('stop');
  const modelBtn = document.getElementById('model');
  const chips = document.getElementById('chips');
  const tools = new Map(); // callID -> { el, body, nested }
  let todosEl = null;
  let streaming = null; // mensaje del asistente que recibe text_delta

  function scroll() { log.scrollTop = log.scrollHeight; }

  function add(cls, text, parent) {
    const d = document.createElement('div');
    d.className = 'msg ' + cls;
    d.textContent = text; // textContent: nunca HTML de la respuesta
    (parent || log).appendChild(d);
    scroll();
    return d;
  }

  function fillText(d, text) {
    d.textContent = '';
    text.split('```').forEach(function (p, i) {
      if (i % 2 === 1) {
        const pre = document.createElement('pre');
        pre.textContent = p.replace(/^[^\n]*\n/, '');
        d.appendChild(pre);
      } else if (p) {
        d.appendChild(document.createTextNode(p));
      }
    });
  }

  function renderText(text, parent) {
    if (!parent && streaming) { fillText(streaming, text); streaming = null; scroll(); return; }
    const d = document.createElement('div');
    d.className = 'msg assistant';
    fillText(d, text);
    (parent || log).appendChild(d);
    scroll();
  }

  function delta(text) {
    if (!streaming) {
      streaming = document.createElement('div');
      streaming.className = 'msg assistant';
      streaming.dataset.raw = '';
      log.appendChild(streaming);
    }
    streaming.dataset.raw += text;
    streaming.textContent = streaming.dataset.raw;
    scroll();
  }

  function preBlock(label, text) {
    const wrap = document.createElement('div');
    const l = document.createElement('div');
    l.className = 'label';
    l.textContent = label;
    const pre = document.createElement('pre');
    pre.textContent = text.length > 6000 ? text.slice(0, 6000) + '\n… (recortado)' : text;
    wrap.appendChild(l);
    wrap.appendChild(pre);
    return wrap;
  }

  // Herramienta plegable: resumen con estado y título; dentro, entrada, salida y subagente anidado.
  function toolEvent(e, parent) {
    const key = (parent ? 'n:' : '') + e.id;
    let t = tools.get(key);
    if (!t) {
      const el = document.createElement('details');
      el.className = 'msg tool running';
      const sum = document.createElement('summary');
      el.appendChild(sum);
      const body = document.createElement('div');
      el.appendChild(body);
      (parent || log).appendChild(el);
      t = { el: el, sum: sum, body: body, nested: null, shown: false };
      tools.set(key, t);
    }
    const st = e.status === 'completed' ? 'done' : e.status === 'error' ? 'failed' : 'running';
    t.el.className = 'msg tool ' + st;
    t.sum.textContent = e.tool + (e.title && e.title !== e.tool ? '  ' + e.title : '');
    if (e.input && !t.shown) {
      t.body.appendChild(preBlock('entrada', JSON.stringify(e.input, null, 2)));
      t.shown = true;
    }
    if (typeof e.output === 'string' && st !== 'running') {
      t.body.appendChild(preBlock(st === 'failed' ? 'error' : 'salida', e.output));
    }
    scroll();
    return t;
  }

  function subagent(e) {
    const parent = tools.get(e.callId);
    if (!parent) return;
    if (!parent.nested) {
      parent.nested = document.createElement('div');
      parent.nested.className = 'nested';
      parent.body.appendChild(parent.nested);
    }
    const inner = e.event;
    if (inner.kind === 'tool') toolEvent(inner, parent.nested);
    else if (inner.kind === 'text') renderText(inner.text, parent.nested);
    else if (inner.kind === 'error') add('error', inner.message, parent.nested);
  }

  function todos(list) {
    if (!todosEl) {
      todosEl = document.createElement('div');
      todosEl.className = 'msg todos';
      log.appendChild(todosEl);
    }
    todosEl.textContent = '';
    list.forEach(function (t) {
      const li = document.createElement('div');
      li.className = 'todo ' + t.status;
      const mark = t.status === 'completed' ? '☑' : t.status === 'in_progress' ? '▶' : t.status === 'cancelled' ? '✗' : '☐';
      li.textContent = mark + ' ' + t.content;
      todosEl.appendChild(li);
    });
    scroll();
  }

  function permission(e) {
    const box = document.createElement('div');
    box.className = 'msg permission';
    const q = document.createElement('div');
    q.textContent = 'Permiso: ' + e.title;
    box.appendChild(q);
    const row = document.createElement('div');
    row.className = 'row';
    [['Permitir', 'once'], ['Siempre', 'always'], ['Rechazar', 'reject']].forEach(function (b) {
      const btn = document.createElement('button');
      btn.type = 'button';
      btn.textContent = b[0];
      btn.addEventListener('click', function () {
        vscode.postMessage({ type: 'permissionReply', id: e.id, reply: b[1] });
        row.remove();
        const done = document.createElement('div');
        done.className = 'meta';
        done.textContent = b[0];
        box.appendChild(done);
      });
      row.appendChild(btn);
    });
    box.appendChild(row);
    log.appendChild(box);
    scroll();
  }

  function renderChips(files) {
    chips.textContent = '';
    files.forEach(function (f) {
      const c = document.createElement('span');
      c.className = 'chip';
      c.title = f.path + ' (clic para quitar)';
      c.textContent = f.name + ' ×';
      c.addEventListener('click', function () { vscode.postMessage({ type: 'detach', file: f.path }); });
      chips.appendChild(c);
    });
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
  input.addEventListener('paste', function (e) {
    const items = (e.clipboardData && e.clipboardData.items) || [];
    for (let i = 0; i < items.length; i++) {
      if (items[i].kind === 'file' && /^image\//.test(items[i].type)) {
        const blob = items[i].getAsFile();
        const mime = items[i].type;
        const r = new FileReader();
        r.onload = function () {
          const s = String(r.result);
          vscode.postMessage({ type: 'attachImage', mime: mime, data: s.slice(s.indexOf(',') + 1) });
        };
        r.readAsDataURL(blob);
        e.preventDefault();
      }
    }
  });
  stop.addEventListener('click', function () { vscode.postMessage({ type: 'stop' }); });
  modelBtn.addEventListener('click', function () { vscode.postMessage({ type: 'pickModel' }); });
  document.getElementById('attach').addEventListener('click', function () { vscode.postMessage({ type: 'attachFiles' }); });
  document.getElementById('new').addEventListener('click', function () { vscode.postMessage({ type: 'newChat' }); });

  window.addEventListener('message', function (ev) {
    const m = ev.data;
    if (m.type === 'user') {
      streaming = null;
      add('user', m.text + (m.files && m.files.length ? '\n📎 ' + m.files.join(', ') : ''));
    } else if (m.type === 'clear') { log.textContent = ''; tools.clear(); todosEl = null; streaming = null; chips.textContent = ''; }
    else if (m.type === 'insert') { input.value += m.text; input.focus(); }
    else if (m.type === 'attached') renderChips(m.files);
    else if (m.type === 'model') modelBtn.textContent = 'modelo: ' + (m.model || 'por defecto');
    else if (m.type === 'busy') {
      send.disabled = m.busy; stop.hidden = !m.busy; input.disabled = m.busy;
      if (!m.busy) { streaming = null; input.focus(); }
    } else if (m.type === 'event') {
      const e = m.event;
      if (e.kind === 'text') renderText(e.text);
      else if (e.kind === 'text_delta') delta(e.text);
      else if (e.kind === 'error') add('error', e.message);
      else if (e.kind === 'tool') toolEvent(e);
      else if (e.kind === 'todo') todos(e.todos);
      else if (e.kind === 'permission') permission(e);
      else if (e.kind === 'subagent') subagent(e);
      else if (e.kind === 'step_finish' && (e.input || e.output)) {
        add('meta', 'tokens: ' + e.input + ' entrada / ' + e.output + ' salida');
      }
    }
  });
})();
