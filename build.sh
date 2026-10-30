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
mkdir -p "$root/out/bin"
export SAL_SDK="$sdk" SAL_LD="$lld"
"$sal" build "$root/src/main.sal" --target soso -o "$root/out/bin/opencode"
"$sal" build "$root/src/coord_main.sal" --target soso -o "$root/out/bin/soso-improve-sal"
echo "built: $root/out/bin/opencode $root/out/bin/soso-improve-sal"
