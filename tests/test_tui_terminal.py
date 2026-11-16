#!/usr/bin/env python3
"""Pantalla alternativa y desplazamiento de la TUI en un terminal real (PTY)."""
import fcntl
import json
import os
import pty
import select
import struct
import subprocess
import sys
import tempfile
import termios
import time
from pathlib import Path


def collect(fd, needle, timeout=8):
    data = b""
    end = time.monotonic() + timeout
    while needle not in data and time.monotonic() < end:
        if select.select([fd], [], [], 0.2)[0]:
            try:
                data += os.read(fd, 65536)
            except OSError:
                break
    assert needle in data, (needle, data[-1000:])
    return data


with tempfile.TemporaryDirectory(prefix="supercoder-terminal-") as tmp:
    Path(tmp, "supercoder.json").write_text(json.dumps({"models": {f"modelo-{i:02}": {} for i in range(90)}}))
    master, slave = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack("HHHH", 24, 100, 0, 0))
    env = dict(os.environ, SUPERCODER_HOME=str(Path(tmp, "home")), TERM="xterm")
    proc = subprocess.Popen([sys.argv[1]], stdin=slave, stdout=slave, stderr=slave, cwd=tmp, env=env)
    os.close(slave)
    try:
        start = collect(master, b"\x1b[20;8H")
        assert b"\x1b[?1049h" in start
        assert b"\x1b[19;1H" in start
        os.write(master, b"/mod")
        collect(master, b"/mod")
        fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack("HHHH", 60, 120, 0, 0))
        resized = collect(master, b"\x1b[56;8H")
        assert b"/mod" in resized or b"/mod" in collect(master, b"/mod")
        os.write(master, b"els\n")
        recent = collect(master, b"modelo-89")
        if b"\x1b[56;8H" not in recent:
            recent += collect(master, b"\x1b[56;8H")
        assert b"\x1b[2J" not in recent
        os.write(master, b"\x1b[5~")
        earlier = collect(master, b"modelo-33")
        assert b"\x1b[2J" not in earlier
        os.write(master, b"\x1b[6~")
        collect(master, b"modelo-89")
        os.write(master, b"exit\n")
        finish = collect(master, b"\x1b[?1049l")
        assert proc.wait(timeout=5) == 0
        assert not finish.split(b"\x1b[?1049l", 1)[1].startswith(b"\r\n")
    finally:
        if proc.poll() is None:
            proc.kill()
            proc.wait()
        os.close(master)
print("OK terminal: pantalla alternativa y navegación del historial")
