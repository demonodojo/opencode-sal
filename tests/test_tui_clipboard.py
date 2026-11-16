#!/usr/bin/env python3
"""Pega imágenes en un PTY y comprueba los adjuntos enviados al modelo."""
import base64
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import pty
import select
import struct
import subprocess
import sys
import tempfile
import termios
import threading
import time
from http.server import HTTPServer

sys.dont_write_bytecode = True
root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("mock_llm", root / "tests/mock_llm.py")
mock = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mock)
png = base64.b64decode("iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+a5wAAAABJRU5ErkJggg==")

def receive(fd, needle, timeout=15):
    out = b""
    deadline = time.monotonic() + timeout
    while needle not in out and time.monotonic() < deadline:
        if select.select([fd], [], [], 0.1)[0]:
            out += os.read(fd, 65536)
    assert needle in out, (needle, out[-2000:])
    return out

with tempfile.TemporaryDirectory(prefix="supercoder-clip-test-") as temp:
    tmp = Path(temp)
    script = tmp / "script.json"
    script.write_text(json.dumps({"steps": [{"type": "content", "text": "respuesta terminada"}]}))
    state = mock.MockState(mock.load_guion(script), tmp / "record")
    server = HTTPServer(("127.0.0.1", 0), mock.make_handler(state))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    (tmp / "supercoder.json").write_text(json.dumps({"models": {"soso-coder": {"port": server.server_port, "vision": True}}}))
    bindir = tmp / "bin"
    bindir.mkdir()
    clip = tmp / "clipboard.png"
    clip.write_bytes(png)
    wl = bindir / "wl-paste"
    wl.write_text('#!/bin/sh\n[ "$2" = image/png ] || exit 1\ncat "$CLIP_TEST_FILE"\n')
    wl.chmod(0o755)
    env = dict(os.environ, SUPERCODER_HOME=str(tmp / "home"), SOSO_LLM_API_KEY="test-key", TERM="xterm", WAYLAND_DISPLAY="test", CLIP_TEST_FILE=str(clip), PATH=str(bindir) + os.pathsep + os.environ["PATH"])
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 100, 0, 0))
    process = subprocess.Popen([sys.argv[1]], stdin=slave, stdout=slave, stderr=slave, cwd=tmp, env=env)
    os.close(slave)
    try:
        receive(master, b"\x1b[20;8H")
        os.write(master, b"Describe ")
        receive(master, b"Describe ")
        os.write(master, b"\x16")
        receive(master, b"[Image]")
        os.write(master, b"\x7f")
        receive(master, b"Describe ")
        os.write(master, b"\x16")
        receive(master, b"[Image]")
        os.write(master, b"\x16")
        receive(master, b"[Image][Image]")
        os.write(master, b"\n")
        try:
            receive(master, b"respuesta terminada", timeout=7)
        except AssertionError as exc:
            raise AssertionError((exc, list((tmp / "record").glob("*")) if (tmp / "record").exists() else [], [(str(p), p.read_text(errors="replace")[:2000]) for p in (tmp / "home").rglob("*.json")]))
        req = json.loads((tmp / "record/peticion-01.json").read_text())
        user = [m for m in req["messages"] if m["role"] == "user"][-1]
        parts = user["content"]
        urls = [p["image_url"]["url"] for p in parts if p["type"] == "image_url"]
        assert len(urls) == 2 and all(base64.b64decode(x.split(",", 1)[1]) == png for x in urls), urls
        os.write(master, b"exit\n")
        assert process.wait(timeout=10) == 0
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()
        os.close(master)
        server.shutdown()
        server.server_close()
print("OK: imágenes del portapapeles, eliminación y adjuntos al modelo")
