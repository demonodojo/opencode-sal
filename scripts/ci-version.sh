#!/usr/bin/env bash
# Imprime la versión del paquete (Sal.toml).
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
grep -E '^version = ' "$root/Sal.toml" | sed -E 's/^version = "([^"]+)"/\1/'
