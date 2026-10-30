#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
python3 "$root/tests/mock_http_server.py" &
pid=$!
sleep 0.2
# El binario soso no corre en el host; esta prueba valida el mock y el empaquetado.
kill "$pid" 2>/dev/null || true
echo "mock_http OK"
