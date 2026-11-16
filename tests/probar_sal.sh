#!/usr/bin/env bash
# Compila y ejecuta tests/sal/test_*.sal (--target linux); con OC_SAL_E2E=1 añade E2E contra tests/mock_llm.py.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
sal="${SAL_BIN:-$root/../sal/target/release/sal}"
if [[ ! -x "$sal" ]]; then
  sal=sal
fi
outdir="$root/tests/out/sal"
mkdir -p "$outdir"
(cd "$root" && "$sal" install >/dev/null)

run_one() {
  local src=$1
  local name
  name=$(basename "$src" .sal)
  "$sal" build "$src" --target linux -o "$outdir/$name"
  # los tests escriben bajo target/ relativo al cwd: partir de un estado limpio
  rm -rf "$root"/target/*test
  (cd "$root" && "$outdir/$name")
  echo "OK $name"
}

unit_tests=(
  "$root/tests/sal/test_base.sal"
  "$root/tests/sal/test_provider.sal"
  "$root/tests/sal/test_tools_rw.sal"
  "$root/tests/sal/test_tools_search.sal"
  "$root/tests/sal/test_registry.sal"
)
extra_tests=("$root"/tests/sal/test_*.sal)
for t in "${extra_tests[@]}"; do
  found=0
  for u in "${unit_tests[@]}"; do [[ "$u" == "$t" ]] && found=1; done
  [[ $found == 0 ]] && unit_tests+=("$t")
done

for src in "${unit_tests[@]}"; do
  run_one "$src"
done

if [[ "${OC_SAL_E2E:-0}" == "1" ]]; then
  bin="$root/out/linux/bin/supercoder"
  python3 "$root/tests/test_skill_discovery.py" "$bin"
  port=7422
  mock_pid=""
  start_mock() {  # start_mock GUION [PUERTO]
    python3 "$root/tests/mock_llm.py" "${2:-$port}" "$1" &
    mock_pid=$!
    sleep 0.4
  }
  stop_mock() {
    if [[ -n "$mock_pid" ]]; then
      kill "$mock_pid" 2>/dev/null || true
      wait "$mock_pid" 2>/dev/null || true
      mock_pid=""
    fi
  }
  trap stop_mock EXIT
  export SUPERCODER_HOME="$root/tests/out/home"
  export SOSO_LLM_API_KEY=test-key
  e2e="$root/tests/out/e2e"
  rm -rf "$e2e" "$SUPERCODER_HOME"; mkdir -p "$e2e"

  # read + edit + texto final: eventos, petición con tools/Bearer y fichero editado
  guion="$root/tests/guiones/read_edit_stop.json"
  rec="$e2e/rec"
  cp -f "$root/tests/fixtures/oc-fixture.txt" /tmp/oc-fixture.txt
  RECORD_DIR="$rec" start_mock "$guion"
  (cd "$e2e" && "$bin" run --format json --yes --session t1 --max-turns 6 "lee y edita /tmp/oc-fixture.txt" > salida.jsonl 2>/dev/null) || true
  stop_mock
  python3 - "$e2e/salida.jsonl" "$rec" <<'PY' || { echo "FALLO: E2E read+edit" >&2; exit 1; }
import json, sys
ev = [json.loads(l) for l in open(sys.argv[1])]
kinds = [e["type"] for e in ev]
assert kinds[0] == "step_start" and kinds[-1] == "step_finish", kinds
tools = [(e["part"]["tool"], e["part"]["state"]["status"]) for e in ev if e["type"] == "tool_use"]
assert ("read", "completed") in tools and ("edit", "completed") in tools, tools
assert [e for e in ev if e["type"] == "text"][-1]["part"]["text"] == "terminado"
assert ev[-1]["part"]["tokens"]["input"] > 0
req = json.load(open(sys.argv[2] + "/peticion-01.json"))
assert req["tool_choice"] == "auto" and len(req["tools"]) >= 7
assert "Bearer test-key" in open(sys.argv[2] + "/cabeceras-01.txt").read()
last = json.load(open(sys.argv[2] + "/peticion-03.json"))["messages"]
assert last[-1]["role"] == "tool" and "tool_call_id" in last[-1]
PY
  grep -q patched /tmp/oc-fixture.txt || { echo "FALLO: el fichero no se editó" >&2; exit 1; }
  test -s "$SUPERCODER_HOME/sessions/t1/messages.json" || { echo "FALLO: sesión no guardada" >&2; exit 1; }
  echo "OK read+edit"

  # --model llega en la petición
  rec="$e2e/modelo"
  RECORD_DIR="$rec" start_mock "$root/tests/guiones/read_then_stop.json"
  "$bin" run --yes --model modelo-prueba --max-turns 1 "hola" >/dev/null 2>&1 || true
  stop_mock
  python3 - "$rec/peticion-01.json" <<'PY' || { echo "FALLO: --model no llegó a la petición" >&2; exit 1; }
import json, sys
assert json.load(open(sys.argv[1]))["model"] == "modelo-prueba"
PY
  echo "OK --model"

  # ollama:NOMBRE -> $OLLAMA_HOST, nombre sin prefijo, sin Authorization
  rec="$e2e/ollama"
  RECORD_DIR="$rec" start_mock "$root/tests/guiones/read_then_stop.json" 7433
  SOSO_LLM_API_KEY=secreto OLLAMA_HOST=http://127.0.0.1:7433/ "$bin" run --yes --model ollama:qwen2.5-coder:7b --max-turns 1 "hola" >/dev/null 2>&1 || true
  stop_mock
  python3 - "$rec/peticion-01.json" <<'PY' || { echo "FALLO: ollama: no llegó a la petición" >&2; exit 1; }
import json, sys
assert json.load(open(sys.argv[1]))["model"] == "qwen2.5-coder:7b"
PY
  grep -q "^POST /v1/chat/completions" "$rec/cabeceras-01.txt" || { echo "FALLO: ollama: ruta" >&2; exit 1; }
  if grep -qi "^authorization" "$rec/cabeceras-01.txt"; then echo "FALLO: ollama no debe llevar Authorization" >&2; exit 1; fi
  echo "OK ollama"

  # lmstudio:ID -> $LMSTUDIO_HOST, id tal cual, sin Authorization
  rec="$e2e/lmstudio"
  RECORD_DIR="$rec" start_mock "$root/tests/guiones/read_then_stop.json" 7433
  SOSO_LLM_API_KEY=secreto LMSTUDIO_HOST=127.0.0.1:7433 "$bin" run --yes --model lmstudio:qwen/qwen3-coder --max-turns 1 "hola" >/dev/null 2>&1 || true
  stop_mock
  python3 - "$rec/peticion-01.json" <<'PY' || { echo "FALLO: lmstudio: no llegó a la petición" >&2; exit 1; }
import json, sys
assert json.load(open(sys.argv[1]))["model"] == "qwen/qwen3-coder"
PY
  if grep -qi "^authorization" "$rec/cabeceras-01.txt"; then echo "FALLO: lmstudio no debe llevar Authorization" >&2; exit 1; fi
  echo "OK lmstudio"

  # "models": cada modelo habla con su puerto
  cfgdir="$e2e/cfg"; mkdir -p "$cfgdir"
  printf '{"model":"otro","models":{"otro":{"port":7433},"base":{"port":7422}}}\n' > "$cfgdir/supercoder.json"
  start_mock "$root/tests/guiones/read_then_stop.json" 7433
  (cd "$cfgdir" && "$bin" run --format json --yes --max-turns 2 "hola" > salida.jsonl 2>/dev/null) || true
  stop_mock
  grep -q tool_use "$cfgdir/salida.jsonl" || { echo "FALLO: models/port no enrutó al puerto 7433" >&2; exit 1; }
  echo "OK models/port"


  # permisos: sin cliente se rechaza `ask`; --yes lo concede
  rm -f /tmp/oc-perm-1 /tmp/oc-perm-2
  start_mock "$root/tests/guiones/bash_ask.json"
  (cd "$e2e" && "$bin" run --format json --session p1 "toca" > perm1.jsonl 2>/dev/null) || true
  stop_mock
  test ! -e /tmp/oc-perm-1 || { echo "FALLO: bash sin permiso se ejecutó" >&2; exit 1; }
  grep -q "no user is available" "$e2e/perm1.jsonl" || { echo "FALLO: falta el rechazo de permiso" >&2; exit 1; }
  start_mock "$root/tests/guiones/bash_ask.json"
  (cd "$e2e" && "$bin" run --format json --yes --session p2 "toca" > perm2.jsonl 2>/dev/null) || true
  stop_mock
  test -e /tmp/oc-perm-1 && test -e /tmp/oc-perm-2 || { echo "FALLO: --yes no ejecutó bash" >&2; exit 1; }
  echo "OK permisos (rechazo y --yes)"

  # permisos interactivos: once, reject y always (la segunda orden "touch" ya no pregunta)
  perm_case() {  # perm_case SESION RESPUESTAS PETICIONES ESTADOS [GUION]
    rm -f /tmp/oc-perm-1 /tmp/oc-perm-2
    start_mock "$root/tests/guiones/${5:-bash_ask}.json"
    res=$(cd "$e2e" && python3 "$root/tests/perm_client.py" "$bin" "$2" "$1")
    stop_mock
    python3 - "$res" "$3" "$4" <<'PY' || { echo "FALLO: permisos interactivos ($1): $res" >&2; exit 1; }
import json, sys
r = json.loads(sys.argv[1])
assert r["requests"] == int(sys.argv[2]), r
assert [t[1] for t in r["tools"]] == sys.argv[3].split(","), r
assert r["last"] == "step_finish", r
PY
  }
  perm_case i1 once,reject 2 completed,error
  test -e /tmp/oc-perm-1 && test ! -e /tmp/oc-perm-2 || { echo "FALLO: once/reject" >&2; exit 1; }
  perm_case i2 always 1 completed,completed
  test -e /tmp/oc-perm-1 && test -e /tmp/oc-perm-2 || { echo "FALLO: always" >&2; exit 1; }
  perm_case i3 always 1 completed,completed   # sesión nueva: vuelve a preguntar
  echo "OK permisos interactivos"

  # subagentes: el padre lanza `supercoder run --agent explore`, anida sus eventos y usa su informe
  cp -f "$root/tests/fixtures/oc-fixture.txt" /tmp/oc-fixture.txt
  rec="$e2e/sub"
  RECORD_DIR="$rec" start_mock "$root/tests/guiones/subagent.json"
  (cd "$e2e" && "$bin" run --format json --yes --session s1 "investiga" > sub.jsonl 2>/dev/null) || true
  stop_mock
  python3 - "$e2e/sub.jsonl" "$rec" <<'PY' || { echo "FALLO: subagentes" >&2; exit 1; }
import json, sys
ev = [json.loads(l) for l in open(sys.argv[1])]
subs = [e for e in ev if e["type"] == "subagent"]
assert subs, "sin eventos subagent"
assert all(e["part"]["callID"] == "call_1" for e in subs)
inner = [e["part"]["event"]["type"] for e in subs]
assert "tool_use" in inner and "text" in inner, inner
assert [e for e in ev if e["type"] == "text"][-1]["part"]["text"] == "padre listo"
tools = [(e["part"]["tool"], e["part"]["state"]["status"]) for e in ev if e["type"] == "tool_use"]
assert tools == [("task", "running"), ("task", "completed")], tools
# el hijo recibió el prompt de la tarea y no tiene la herramienta task; el padre recibió el informe
child = json.load(open(sys.argv[2] + "/peticion-02.json"))
assert "Lee /tmp/oc-fixture.txt" in child["messages"][1]["content"]
assert "task" not in [t["function"]["name"] for t in child["tools"]]
assert "write" not in [t["function"]["name"] for t in child["tools"]]
parent = json.load(open(sys.argv[2] + "/peticion-04.json"))
assert parent["messages"][-1]["role"] == "tool" and "informe del hijo" in parent["messages"][-1]["content"]
assert "task" in [t["function"]["name"] for t in json.load(open(sys.argv[2] + "/peticion-01.json"))["tools"]]
PY
  echo "OK subagentes"
  perm_case sb1 once 1 completed subagent_bash
  test -e /tmp/oc-perm-1 || { echo "FALLO: permiso del subagente no reenviado" >&2; exit 1; }
  echo "OK permisos de subagente"
  "$bin" agents | grep -q "^explore (subagent)" || { echo "FALLO: supercoder agents" >&2; exit 1; }
  echo "OK agents"

  # multimodalidad: con visión la imagen va como image_url; sin visión nunca; con vision_model se describe
  python3 -c "open('$e2e/pic.png','wb').write(bytes.fromhex('89504e470d0a1a0a0000000d49484452'))"
  vdir="$e2e/vision"; mkdir -p "$vdir"
  printf '{"models":{"soso-coder":{"port":7422,"vision":true}}}\n' > "$vdir/supercoder.json"
  RECORD_DIR="$vdir/rec1" start_mock "$root/tests/guiones/solo_texto.json"
  (cd "$vdir" && "$bin" run --format json --yes --file "$e2e/pic.png" "que ves" > o1.jsonl 2>/dev/null) || true
  stop_mock
  printf '{"models":{"soso-coder":{"port":7422}}}\n' > "$vdir/supercoder.json"
  RECORD_DIR="$vdir/rec2" start_mock "$root/tests/guiones/solo_texto.json"
  (cd "$vdir" && "$bin" run --format json --yes "que ves @$e2e/pic.png" > o2.jsonl 2>/dev/null) || true
  stop_mock
  printf '{"vision_model":"vm","models":{"soso-coder":{"port":7422},"vm":{"port":7433,"vision":true}}}\n' > "$vdir/supercoder.json"
  RECORD_DIR="$vdir/rec3" start_mock "$root/tests/guiones/solo_texto.json"
  RECORD_DIR="$vdir/rec4" python3 "$root/tests/mock_llm.py" 7433 "$root/tests/guiones/descripcion.json" &
  vm_pid=$!
  sleep 0.4
  (cd "$vdir" && "$bin" run --format json --yes --file "$e2e/pic.png" "que ves" > o3.jsonl 2>/dev/null) || true
  kill "$vm_pid" 2>/dev/null || true
  stop_mock
  python3 - "$vdir" <<'PY' || { echo "FALLO: multimodalidad" >&2; exit 1; }
import json, sys
d = sys.argv[1]
r1 = open(d + "/rec1/peticion-01.json").read()
assert '"image_url"' in r1 and "data:image/png;base64,iVBORw0KGgo" in r1, "con visión debe enviar la imagen"
r2 = open(d + "/rec2/peticion-01.json").read()
assert "image_url" not in r2 and "data:image" not in r2, "sin visión no debe enviar la imagen"
assert "no \\\"vision_model\\\" is configured" in r2, r2[-600:]
r3 = open(d + "/rec3/peticion-01.json").read()
assert "image_url" not in r3 and "una captura con un boton rojo" in r3, "la descripción debe sustituir a la imagen"
r4 = open(d + "/rec4/peticion-01.json").read()
assert '"image_url"' in r4, "el modelo de visión recibe la imagen"
for f in ("o1", "o2", "o3"):
    ev = [json.loads(l) for l in open(d + "/" + f + ".jsonl")]
    assert ev[-1]["type"] == "step_finish", f
PY
  echo "OK multimodalidad"

  # streaming: argumentos de herramienta fragmentados, deltas de texto y tokens de include_usage
  sdir="$e2e/stream"; mkdir -p "$sdir"
  printf '{"models":{"soso-coder":{"port":7422,"stream":true}}}\n' > "$sdir/supercoder.json"
  cp -f "$root/tests/fixtures/oc-fixture.txt" /tmp/oc-fixture.txt
  RECORD_DIR="$sdir/rec" start_mock "$root/tests/guiones/stream.json"
  (cd "$sdir" && "$bin" run --format json --yes "lee" > salida.jsonl 2>/dev/null) || true
  stop_mock
  python3 - "$sdir" <<'PY' || { echo "FALLO: streaming" >&2; exit 1; }
import json, sys
d = sys.argv[1]
ev = [json.loads(l) for l in open(d + "/salida.jsonl")]
deltas = [e["part"]["text"] for e in ev if e["type"] == "text_delta"]
assert deltas == ["ter", "mina", "do"], deltas
assert [e for e in ev if e["type"] == "text"][-1]["part"]["text"] == "terminado"
assert ("read", "completed") in [(e["part"]["tool"], e["part"]["state"]["status"]) for e in ev if e["type"] == "tool_use"]
fin = [e for e in ev if e["type"] == "step_finish"]
assert fin[0]["part"]["tokens"]["input"] == 50 and fin[-1]["part"]["tokens"]["input"] == 120, fin
req = json.load(open(d + "/rec/peticion-01.json"))
assert req["stream"] is True and req["stream_options"] == {"include_usage": True}
call = json.load(open(d + "/rec/peticion-02.json"))["messages"][-2]["tool_calls"][0]
assert json.loads(call["function"]["arguments"]) == {"filePath": "/tmp/oc-fixture.txt"}, call
PY
  echo "OK streaming"

  # compactación: nueve lecturas grandes con un presupuesto pequeño
  python3 -c "print('\n'.join('linea %03d ' % i + 'x' * 40 for i in range(120)))" > /tmp/oc-big.txt
  cmpdir="$e2e/compact"; mkdir -p "$cmpdir"
  printf '{"models":{"soso-coder":{"port":7422,"context_chars":6000}}}\n' > "$cmpdir/supercoder.json"
  RECORD_DIR="$cmpdir/rec" start_mock "$root/tests/guiones/compact.json"
  (cd "$cmpdir" && "$bin" run --format json --yes --session c1 "lee mucho" > salida.jsonl 2>/dev/null) || true
  stop_mock
  python3 - "$cmpdir" <<'PY' || { echo "FALLO: compactación" >&2; exit 1; }
import glob, json, sys
d = sys.argv[1]
ev = [json.loads(l) for l in open(d + "/salida.jsonl")]
assert ev[-1]["type"] == "step_finish", ev[-1]
reqs = sorted(glob.glob(d + "/rec/peticion-*.json"))
last = json.load(open(reqs[-1]))["messages"]
assert any("compacted to save context" in str(m.get("content")) for m in last), "sin resumen"
assert len(last) < 20, len(last)
PY
  echo "OK compactación"

  # skills: /nombre carga el skill (con bloque ">-"), multiedit y un proceso en segundo plano no bloquea bash
  sk="$e2e/skills"; mkdir -p "$sk/.claude/skills/demo/scripts"
  printf -- '---\nname: demo\ndescription: >-\n  Demo skill\n  for tests.\n---\nHaz la demo con $ARGUMENTS.\n' > "$sk/.claude/skills/demo/SKILL.md"
  echo 'echo hi' > "$sk/.claude/skills/demo/scripts/run.sh"
  printf 'uno\ndos\n' > "$sk/multi.txt"
  rec="$e2e/skills-rec"
  RECORD_DIR="$rec" start_mock "$root/tests/guiones/solo_texto.json"
  (cd "$sk" && "$bin" run --format json --yes --session k1 "/demo la compilación" > "$e2e/k1.jsonl" 2>/dev/null) || true
  stop_mock
  python3 - "$rec" <<'PY' || { echo "FALLO: skills /nombre" >&2; exit 1; }
import json, sys
req = json.load(open(sys.argv[1] + "/peticion-01.json"))
system = req["messages"][0]["content"]
user = req["messages"][1]["content"]
assert "- demo: Demo skill for tests." in system, system[-600:]
assert "The user invoked the skill \"demo\"" in user and "Haz la demo con la compilación." in user, user
assert "scripts/run.sh" in user
assert "skill" in [t["function"]["name"] for t in req["tools"]]
PY
  rec="$e2e/multi-rec"
  RECORD_DIR="$rec" start_mock "$root/tests/guiones/multiedit_bg.json"
  t0=$(date +%s)
  (cd "$sk" && "$bin" run --format json --yes --session k2 "edita" > "$e2e/k2.jsonl" 2>/dev/null) || true
  t1=$(date +%s)
  stop_mock
  python3 - "$e2e/k2.jsonl" "$sk/multi.txt" "$((t1 - t0))" <<'PY' || { echo "FALLO: multiedit/bash" >&2; exit 1; }
import json, sys
ev = [json.loads(l) for l in open(sys.argv[1])]
done = [(e["part"]["tool"], e["part"]["state"]["status"]) for e in ev if e["type"] == "tool_use" and e["part"]["state"]["status"] != "running"]
assert done == [("multiedit", "completed"), ("bash", "completed"), ("skill", "completed")], done
assert open(sys.argv[2]).read() == "1\n2\n"
bash = [e for e in ev if e["type"] == "tool_use" and e["part"]["tool"] == "bash" and e["part"]["state"]["status"] == "completed"][0]
assert bash["part"]["state"]["output"].strip() == "lanzado", bash["part"]["state"]["output"]
assert int(sys.argv[3]) < 20, "bash esperó al proceso en segundo plano: %ss" % sys.argv[3]
PY
  echo "OK skills y herramientas nuevas"

  # backend `claude -p`: claude falso en PATH que emite stream-json (init, herramienta, texto, resultado)
  fakebin="$e2e/fakebin"; mkdir -p "$fakebin"
  cat > "$fakebin/claude" <<'SH'
#!/bin/sh
case "$*" in *"--output-format stream-json"*) ;; *) echo "faltan flags: $*" >&2; exit 3;; esac
if [ -n "$FAKE_CLAUDE_FAIL" ]; then echo "boom en stderr" >&2; exit 4; fi
echo '{"type":"system","subtype":"init","model":"fake-model","session_id":"s-1"}'
echo '{"type":"assistant","message":{"content":[{"type":"tool_use","id":"t1","name":"Bash","input":{"command":"ls","description":"lista"}}]}}'
sleep "${FAKE_CLAUDE_SLEEP:-0}"
echo '{"type":"user","message":{"content":[{"type":"tool_result","tool_use_id":"t1","content":"a.txt","is_error":false}]}}'
printf '{"type":"assistant","message":{"content":[{"type":"text","text":"args: %s"}]}}\n' "$*"
echo '{"type":"result","is_error":false,"result":"final","usage":{"input_tokens":5,"output_tokens":7}}'
SH
  chmod +x "$fakebin/claude"
  salida=$(cd "$cfgdir" && rm -f supercoder.json && FAKE_CLAUDE_SLEEP=12 PATH="$fakebin:$PATH" "$bin" run --format json --model claude:sonnet "di hola")
  python3 - "$salida" <<'PY' || { echo "FALLO: backend claude -p" >&2; exit 1; }
import json, sys
ev = [json.loads(l) for l in sys.argv[1].splitlines()]
kinds = [e["type"] for e in ev]
assert kinds[0] == "step_start" and kinds[-1] == "step_finish", kinds
st = [e["part"]["text"] for e in ev if e["type"] == "status"]
assert st[0].startswith("lanzando claude -p (modelo sonnet)"), st
assert any("fake-model" in t for t in st), st
assert any("sigue en marcha" in t for t in st), st
assert st[-1].startswith("claude terminó"), st
tools = [(e["part"]["tool"], e["part"]["state"]["status"]) for e in ev if e["type"] == "tool_use"]
assert tools == [("Bash", "running"), ("Bash", "completed")], tools
txt = [e for e in ev if e["type"] == "text"][0]["part"]["text"]
assert txt.startswith("args: -p --output-format stream-json --verbose --model sonnet --") and "di hola" in txt, txt
assert ev[-1]["part"]["tokens"] == {"input": 5, "output": 7, "reasoning": 0}, ev[-1]
PY
  # fallo de claude: el error incluye su stderr y el código de salida es 1
  set +e
  salida=$(cd "$cfgdir" && FAKE_CLAUDE_FAIL=1 PATH="$fakebin:$PATH" "$bin" run --format json --model claude:sonnet "di hola"); rc=$?
  set -e
  python3 - "$salida" "$rc" <<'PY' || { echo "FALLO: claude -p con error" >&2; exit 1; }
import json, sys
ev = [json.loads(l) for l in sys.argv[1].splitlines()]
err = [e for e in ev if e["type"] == "error"]
assert err and "código 4" in err[0]["error"]["data"]["message"] and "boom en stderr" in err[0]["error"]["data"]["message"], err
assert ev[-1]["type"] == "step_finish" and ev[-1]["part"]["reason"] == "error"
assert sys.argv[2] == "1", sys.argv[2]
PY
  # sin claude en el PATH
  set +e
  salida=$(cd "$cfgdir" && PATH="/nonexistent" "$bin" run --format json --model claude:sonnet "di hola"); rc=$?
  set -e
  case "$salida" in *"no se pudo lanzar claude"*) ;; *) echo "FALLO: claude ausente: $salida" >&2; exit 1;; esac
  echo "OK claude -p"
fi

echo "probar_sal: ${#unit_tests[@]} unitarios OK"
