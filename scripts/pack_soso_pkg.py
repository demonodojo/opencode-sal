#!/usr/bin/env python3
"""Genera paquete soso-pkg (paquete.txt + paquete.pack) desde out/bin/."""
from __future__ import annotations

import argparse
import hashlib
import re
import tarfile
from pathlib import Path

ABI_DEFAULT = 1
NOMBRE = "opencode-sal"


def read_version(root: Path) -> str:
    text = (root / "Sal.toml").read_text(encoding="utf-8")
    m = re.search(r'^version = "([^"]+)"', text, re.M)
    if not m:
        raise SystemExit("Sal.toml: falta version")
    return m.group(1)


def hex_sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def empaquetar(version: str, abi: int, files: list[tuple[str, bytes]]) -> tuple[str, bytes]:
    files = sorted(files, key=lambda x: x[0])
    lines = ["SOSOPKG v1\n", f"nombre={NOMBRE}\n", f"version={version}\n", f"abi={abi}\n"]
    blob = bytearray()
    for path, data in files:
        if not data:
            raise SystemExit(f"fichero vacío: {path}")
        h = hex_sha256(data)
        lines.append(f"f {h} {len(data)} {path}\n")
        blob.extend(data)
    return "".join(lines), bytes(blob)


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    ap.add_argument("--abi", type=int, default=ABI_DEFAULT)
    ap.add_argument("--out-dir", type=Path, default=None)
    args = ap.parse_args()
    root = args.root
    ver = read_version(root)
    oc = (root / "out/bin/opencode").read_bytes()
    imp = (root / "out/bin/soso-improve-sal").read_bytes()
    ver_line = f"opencode-sal {ver}\n".encode()
    files = [
        ("bin/opencode", oc),
        ("bin/soso-improve-sal", imp),
        ("share/opencode/VERSION", ver_line),
    ]
    man_text, pack = empaquetar(ver, args.abi, files)
    out_dir = args.out_dir or (root / "dist" / f"opencode-sal-{ver}-soso-pkg")
    out_dir.mkdir(parents=True, exist_ok=True)
    (out_dir / "paquete.txt").write_text(man_text, encoding="utf-8")
    (out_dir / "paquete.pack").write_bytes(pack)
    for path, data in files:
        dest = out_dir / path
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(data)
    tarball = root / "dist" / f"opencode-sal-{ver}-soso-pkg.tar.gz"
    tarball.parent.mkdir(parents=True, exist_ok=True)
    with tarfile.open(tarball, "w:gz") as tf:
        for p in sorted(out_dir.rglob("*")):
            if p.is_file():
                tf.add(p, arcname=str(p.relative_to(out_dir)))
    print(tarball)


if __name__ == "__main__":
    main()
