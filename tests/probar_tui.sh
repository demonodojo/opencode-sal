#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
"$root/build.sh"
export SUPERCODER_HOME="$root/tests/out/home-tui"
export SOSO_LLM_API_KEY=test-key
rm -rf "$SUPERCODER_HOME"
cp -f "$root/tests/fixtures/oc-fixture.txt" /tmp/oc-fixture.txt
python3 "$root/tests/mock_llm.py" 7422 "$root/tests/guiones/read_then_stop.json" &
pid=$!
sleep 0.4
out=$(printf 'lee /tmp/oc-fixture.txt\ns\nexit\n' | "$root/out/linux/bin/supercoder")
kill "$pid" 2>/dev/null || true
echo "$out" | grep -q 'permiso: external_directory'
echo "$out" | grep -q 'tool read'
echo "$out" | grep -q 'terminado'
echo "linux TUI session + mock E2E OK"
