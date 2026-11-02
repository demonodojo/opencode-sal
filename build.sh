#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")" && pwd)
soso=${SOSO_ROOT:-"$root/../soso"}
sal=${SAL_BIN:-"$root/../sal/target/release/sal"}
if [[ ! -x "$sal" ]]; then
  sal=sal
fi
sdk="$soso/target/sal/sdk"
lld=$(rustc --print sysroot)/lib/rustlib/x86_64-unknown-linux-gnu/bin/rust-lld
mkdir -p "$root/out/bin" "$root/out/linux/bin"
export SAL_SDK="$sdk" SAL_LD="$lld"
# Enlaza sal_modules/io (std) y sal_modules/salkit según Sal.toml.
(cd "$root" && "$sal" install)

build_one() {
  local target=$1
  local outdir=$2
  "$sal" build "$root/src/main.sal" --target "$target" -o "$outdir/supercoder"
  "$sal" build "$root/src/coord_main.sal" --target "$target" -o "$outdir/soso-improve-sal"
}

build_one soso "$root/out/bin"
# Binarios nativos Linux (el compilador resuelve io; el runtime emula la ABI en host).
unset SAL_SDK
build_one linux "$root/out/linux/bin"

echo "built soso: $root/out/bin/supercoder $root/out/bin/soso-improve-sal"
echo "built linux: $root/out/linux/bin/supercoder $root/out/linux/bin/soso-improve-sal"
