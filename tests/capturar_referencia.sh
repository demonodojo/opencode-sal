#!/usr/bin/env bash
# Captura golden con OpenCode real (1.18.x) o importa fixtures de soso.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
golden="$root/tests/golden"
guiones="$root/tests/guiones"
soso_oc="$root/../soso/tests/self-improvement/opencode"
ref_opencode="${OPENCODE_BIN:-$HOME/.opencode/bin/opencode}"

mkdir -p "$golden"

import_soso_fixtures() {
  local dest="$golden/soso-wire-4turn"
  mkdir -p "$dest"
  for i in 1 2 3 4; do
    cp "$soso_oc/peticion-0${i}"*.json "$dest/peticion-$(printf '%02d' "$i").json" 2>/dev/null || true
    cp "$soso_oc/cabeceras-0${i}.txt" "$dest/cabeceras-$(printf '%02d' "$i").txt" 2>/dev/null || true
  done
  cp "$soso_oc/titulo-sin-desactivar.json" "$dest/" 2>/dev/null || true
  echo "importado soso-wire-4turn"
}

capture_guion() {
  local name="$1"
  local port="$2"
  local work="$root/tests/work/capture-$name"
  mkdir -p "$work" "$golden/$name"
  python3 "$root/tests/mock_llm.py" "$port" "$guiones/${name}.json" &
  local pid=$!
  sleep 0.5
  cat >"$work/opencode.json" <<EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "model": "soso/soso-coder",
  "provider": {
    "soso": {
      "options": {
        "baseURL": "http://127.0.0.1:${port}/v1",
        "apiKey": "test"
      },
      "models": {
        "soso-coder": { "limit": { "context": 32768, "output": 2048 } }
      }
    }
  },
  "agent": { "title": { "disable": true } }
}
EOF
  RECORD_DIR="$golden/$name" "$ref_opencode" run --format json --agent soso-improve "lee /tmp/oc-fixture.txt" \
    >"$golden/$name/eventos.jsonl" 2>"$golden/$name/stderr.txt" || true
  "$ref_opencode" run --agent soso-improve "lee /tmp/oc-fixture.txt" \
    >"$golden/$name/salida.txt" 2>/dev/null || true
  kill "$pid" 2>/dev/null || true
  wait "$pid" 2>/dev/null || true
}

if [[ -x "$ref_opencode" ]]; then
  "$ref_opencode" --version >"$golden/opencode-version.txt" 2>&1 || true
  "$ref_opencode" run --help >"$golden/run-help.txt" 2>&1 || true
  for g in "$guiones"/*.json; do
    base=$(basename "$g" .json)
    capture_guion "$base" $((7400 + RANDOM % 50))
  done
else
  echo "OpenCode real no encontrado en $ref_opencode; solo import soso" >&2
fi

import_soso_fixtures
echo "captura en $golden"
