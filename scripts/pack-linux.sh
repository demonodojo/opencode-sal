#!/usr/bin/env bash
# Tarball con binarios Linux nativos (out/linux/bin).
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
ver=$("$root/scripts/ci-version.sh")
stage="$root/dist/stage-linux"
mkdir -p "$stage/bin"
cp "$root/out/linux/bin/opencode" "$root/out/linux/bin/soso-improve-sal" "$stage/bin/"
printf 'opencode-sal %s\n' "$ver" >"$stage/VERSION"
out="$root/dist/opencode-sal-${ver}-linux-x86_64.tar.gz"
mkdir -p "$root/dist"
tar -C "$stage" -czf "$out" .
echo "$out"
