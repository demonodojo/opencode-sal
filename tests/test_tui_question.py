#!/usr/bin/env python3
"""Comprueba las preguntas en la TUI y su respuesta en la siguiente petición al modelo."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
from http.server import HTTPServer

sys.dont_write_bytecode = True
root = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location("mock_llm", root / "tests/mock_llm.py")
mock = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mock)
with tempfile.TemporaryDirectory(prefix="supercoder-question-") as tmp:
    tmp = Path(tmp)
    script = tmp / "script.json"
    script.write_text(json.dumps({"steps": [
        {"type": "tool_calls", "name": "question", "arguments": {"question": "¿Qué color?", "options": ["rojo", "azul"]}},
        {"type": "content", "text": "terminado"},
    ]}))
    state = mock.MockState(mock.load_guion(script), tmp / "record")
    server = HTTPServer(("127.0.0.1", 0), mock.make_handler(state))
    thread = threading.Thread(target=server.serve_forever, daemon=True)
    thread.start()
    (tmp / "supercoder.json").write_text(json.dumps({"models": {"soso-coder": {"port": server.server_port}}}))
    env = dict(os.environ, SUPERCODER_HOME=str(tmp / "home"), SOSO_LLM_API_KEY="test-key", TERM="dumb")
    try:
        run = subprocess.run([sys.argv[1]], input="hola\n2\nexit\n", text=True, capture_output=True, cwd=tmp, env=env, timeout=30)
    finally:
        server.shutdown()
        server.server_close()
    assert run.returncode == 0, (run.returncode, run.stderr)
    assert "¿Qué color?" in run.stdout and "1. rojo" in run.stdout and "2. azul" in run.stdout
    assert "terminado" in run.stdout, run.stdout
    request = json.loads((tmp / "record/peticion-02.json").read_text())
    assert any(m.get("role") == "tool" and m.get("content") == "azul" for m in request["messages"]), request
print("OK pregunta TUI: opciones, respuesta y continuación")
