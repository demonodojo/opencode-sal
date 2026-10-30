#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
"$root/build.sh"
python3 "$root/tests/mock_http_server.py" 7422 &
pid=$!
sleep 0.3
"$root/out/linux/bin/opencode" --version
"$root/out/linux/bin/opencode" run --format json --max-turns 1 "lee /tmp/oc-fixture.txt" | head -5
kill "$pid" 2>/dev/null || true
echo "linux build + mock E2E OK"
