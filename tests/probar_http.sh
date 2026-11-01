#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
"$root/build.sh"
chmod +x "$root/tests/probar_sal.sh"
"$root/tests/probar_sal.sh"
OC_SAL_E2E=1 OC_MOCK_PORT=7422 "$root/tests/probar_sal.sh"
echo "linux build + sal tests + mock E2E OK"
