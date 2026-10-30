#!/usr/bin/env bash
# Build completo + artefactos linux y soso-pkg en dist/.
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
sal_root=${SAL_ROOT:-"$root/../sal"}
soso_root=${SOSO_ROOT:-"$root/../soso"}

if [[ ! -d "$sal_root" || ! -d "$soso_root" ]]; then
  echo "release-build: faltan repos hermanos sal/ y soso/ (SAL_ROOT, SOSO_ROOT)" >&2
  exit 1
fi

export SOSO_ROOT="$soso_root"
export SAL_BIN="$sal_root/target/release/sal"

if [[ ! -x "$SAL_BIN" ]]; then
  (cd "$sal_root" && cargo build --locked --release --bin sal)
fi

if [[ ! -d "$soso_root/target/sal/sdk" ]]; then
  (cd "$soso_root" && cargo xtask sal-build --cross-only)
fi

"$root/build.sh"
"$root/scripts/pack-linux.sh"
python3 "$root/scripts/pack_soso_pkg.py" --root "$root"
