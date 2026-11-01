#!/usr/bin/env bash
# Compila y ejecuta tests/sal/test_*.sal (--target linux).
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
sal="${SAL_BIN:-$root/../sal/target/release/sal}"
if [[ ! -x "$sal" ]]; then
  sal=sal
fi
outdir="$root/tests/out/sal"
mkdir -p "$outdir"

run_one() {
  local src=$1
  local name
  name=$(basename "$src" .sal)
  "$sal" build "$src" --target linux -o "$outdir/$name"
  "$outdir/$name"
  echo "OK $name"
}

unit_tests=(
  "$root/tests/sal/test_json_esc.sal"
  "$root/tests/sal/test_extract_quoted.sal"
  "$root/tests/sal/test_parse_tool.sal"
  "$root/tests/sal/test_sse.sal"
  "$root/tests/sal/test_config_model.sal"
)

for src in "${unit_tests[@]}"; do
  run_one "$src"
done

if [[ "${OC_SAL_E2E:-0}" == "1" ]]; then
  port=7422  # test_http_mock y supercoder usan 7422 fijo (getenv de Sal recursa en linux)
  guion="${OC_MOCK_GUION:-$root/tests/guiones/read_then_stop.json}"
  mock_pid=""
  start_mock() {
    python3 "$root/tests/mock_llm.py" "$port" "$guion" &
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
  export OC_MOCK_PORT="$port"
  start_mock
  run_one "$root/tests/sal/test_http_mock.sal"
  stop_mock
  # guion fresco: test_http_mock consume el primer paso
  start_mock
  fixture="$root/tests/fixtures/oc-fixture.txt"
  cp -f "$fixture" /tmp/oc-fixture.txt 2>/dev/null || true
  "$root/out/linux/bin/supercoder" run --format json --max-turns 2 "lee /tmp/oc-fixture.txt" \
    > /tmp/supercoder-sal-test-run.jsonl 2>/dev/null || true
  stop_mock
  run_one "$root/tests/sal/test_supercoder_run.sal"

  # --model llega en la petición; sin él se usa el modelo por defecto
  rec="$root/tests/out/modelo"
  rm -rf "$rec"
  RECORD_DIR="$rec" start_mock
  "$root/out/linux/bin/supercoder" run --model modelo-prueba --max-turns 1 "hola" >/dev/null 2>&1 || true
  stop_mock
  python3 - "$rec/peticion-01.json" <<'PY' || { echo "FALLO: --model no llegó a la petición (o JSON inválido)" >&2; exit 1; }
import json, sys
assert json.load(open(sys.argv[1]))["model"] == "modelo-prueba"
PY
  echo "OK --model"

  # "models": cada modelo habla con su puerto
  cfgdir="$root/tests/out/cfg"
  rm -rf "$cfgdir"; mkdir -p "$cfgdir"
  printf '{"model":"otro","models":{"otro":{"port":7433},"base":{"port":7422}}}\n' > "$cfgdir/supercoder.json"
  python3 "$root/tests/mock_llm.py" 7433 "$guion" &
  mock_pid=$!
  sleep 0.4
  (cd "$cfgdir" && "$root/out/linux/bin/supercoder" run --format json --max-turns 2 "hola" > salida.jsonl 2>/dev/null) || true
  stop_mock
  grep -q tool_use "$cfgdir/salida.jsonl" || { echo "FALLO: models/port no enrutó al puerto 7433" >&2; exit 1; }
  echo "OK models/port"

  # backend `claude -p`: claude falso en PATH, comprueba argumentos y JSON escapado
  fakebin="$root/tests/out/fakebin"
  mkdir -p "$fakebin"
  printf '#!/bin/sh\necho "args: $*"\necho "segunda \\"linea\\""\n' > "$fakebin/claude"
  chmod +x "$fakebin/claude"
  salida=$(cd "$cfgdir" && rm -f supercoder.json && PATH="$fakebin:$PATH" "$root/out/linux/bin/supercoder" run --format json --model claude:sonnet "di hola")
  python3 - "$salida" <<'PY' || { echo "FALLO: backend claude -p" >&2; exit 1; }
import json, sys
ev = [json.loads(l) for l in sys.argv[1].splitlines()]
txt = [e for e in ev if e["type"] == "text"][0]["part"]["text"]
assert txt == 'args: -p --model sonnet -- di hola\nsegunda "linea"', txt
assert ev[0]["type"] == "step_start" and ev[-1]["type"] == "step_finish"
PY
  echo "OK claude -p"
fi

echo "probar_sal: ${#unit_tests[@]} unitarios OK"
