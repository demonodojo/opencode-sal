#!/usr/bin/env python3
"""Adjunta una imagen por ruta en la TUI, sin portapapeles gráfico (alternativa en soso)."""
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


with tempfile.TemporaryDirectory(prefix="supercoder-path-test-") as temp:
    tmp = Path(temp)
    script = tmp / "script.json"
    script.write_text(json.dumps({"steps": [{"type": "content", "text": "respuesta terminada"}]}))
    state = mock.MockState(mock.load_guion(script), tmp / "record")
    server = HTTPServer(("127.0.0.1", 0), mock.make_handler(state))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    (tmp / "supercoder.json").write_text(json.dumps({"models": {"soso-coder": {"port": server.server_port, "vision": True}}}))
    image = tmp / "captura.png"
    image.write_bytes(png)
    env = dict(os.environ, SUPERCODER_HOME=str(tmp / "home"), SOSO_LLM_API_KEY="test-key", TERM="xterm")
    env.pop("WAYLAND_DISPLAY", None)
    env.pop("DISPLAY", None)
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 100, 0, 0))
    process = subprocess.Popen([sys.argv[1]], stdin=slave, stdout=slave, stderr=slave, cwd=tmp, env=env)
    os.close(slave)
    try:
        receive(master, b"\x1b[20;8H")
        os.write(master, (str(image) + "\n").encode())
        try:
            receive(master, b"respuesta terminada", timeout=7)
        except AssertionError as exc:
            raise AssertionError((exc, list((tmp / "record").glob("*")) if (tmp / "record").exists() else [], [(str(p), p.read_text(errors="replace")[:2000]) for p in (tmp / "home").rglob("*.json")]))
        req = json.loads((tmp / "record/peticion-01.json").read_text())
        user = [m for m in req["messages"] if m["role"] == "user"][-1]
        parts = user["content"]
        urls = [p["image_url"]["url"] for p in parts if p["type"] == "image_url"]
        assert len(urls) == 1 and base64.b64decode(urls[0].split(",", 1)[1]) == png, urls
        assert any(p["type"] == "text" and "[Image]" in p["text"] for p in parts), parts
        os.write(master, b"exit\n")
        assert process.wait(timeout=10) == 0
        assert image.exists(), "la limpieza no debe borrar una imagen adjunta por el usuario"
    finally:
        if process.poll() is None:
            process.kill()
            process.wait()
        os.close(master)
        server.shutdown()
        server.server_close()
print("OK: imagen adjunta por ruta sin portapapeles (soso)")
