#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
"$root/build.sh"
python3 "$root/tests/mock_http_server.py" 7422 &
pid=$!
sleep 0.3
out=$(printf 'lee /tmp/oc-fixture.txt\nexit\n' | "$root/out/linux/bin/opencode")
kill "$pid" 2>/dev/null || true
echo "$out" | grep -q 'tool read'
echo "$out" | grep -q 'terminado'
echo "linux TUI session + mock E2E OK"
