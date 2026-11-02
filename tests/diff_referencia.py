#!/usr/bin/env python3
"""Comprueba que supercoder-sal habla el mismo vocabulario que la referencia (OpenCode real).

No compara bytes: el prompt y los esquemas de herramientas son propios. Verifica, con los guiones
que tienen golden en tests/golden:
  - eventos: step_start primero, step_finish último, tool_use con los campos del golden
    (type, tool, callID, state.status, state.input), step_finish con reason y tokens;
  - petición (golden soso-wire-4turn): mismas claves de primer nivel, mismos nombres de
    herramientas que el golden que supercoder implementa, y forma assistant.tool_calls /
    role:tool con tool_call_id.
"""
from __future__ import annotations

import json
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
GOLDEN = Path(__file__).resolve().parent / "golden"
GUIONES = Path(__file__).resolve().parent / "guiones"
BIN = ROOT / "out" / "linux" / "bin" / "supercoder"
PORT = 7461


def run(guion: str, workdir: Path, rec: Path) -> tuple[int, list[dict]]:
    rec.mkdir(parents=True, exist_ok=True)
    workdir.mkdir(parents=True, exist_ok=True)
    (workdir / "supercoder.json").write_text(json.dumps({"models": {"soso-coder": {"port": PORT}}}))
    env = {**os.environ, "RECORD_DIR": str(rec), "SOSO_LLM_API_KEY": "test",
           "SUPERCODER_HOME": str(workdir / "home")}
    mock = subprocess.Popen([sys.executable, str(ROOT / "tests" / "mock_llm.py"), str(PORT), str(GUIONES / f"{guion}.json")], env=env)
    try:
        time.sleep(0.5)
        (Path("/tmp") / "oc-fixture.txt").write_text((ROOT / "tests" / "fixtures" / "oc-fixture.txt").read_text())
        p = subprocess.run([str(BIN), "run", "--format", "json", "--yes", "lee /tmp/oc-fixture.txt"],
                           cwd=workdir, env=env, capture_output=True, text=True, timeout=60)
        return p.returncode, [json.loads(l) for l in p.stdout.splitlines() if l.strip()]
    finally:
        mock.terminate()
        mock.wait(timeout=5)


def check_events(name: str, events: list[dict], golden: list[dict]) -> list[str]:
    errs: list[str] = []
    if not events or events[0]["type"] != "step_start":
        errs.append(f"{name}: el primer evento debe ser step_start")
    if not events or events[-1]["type"] != "step_finish":
        errs.append(f"{name}: el último evento debe ser step_finish")
    for e in events:
        for k in ("type", "timestamp", "sessionID", "part"):
            if k not in e:
                errs.append(f"{name}: evento sin '{k}': {e['type']}")
    g_tool = next((e for e in golden if e["type"] == "tool_use"), None)
    o_tool = next((e for e in events if e["type"] == "tool_use"), None)
    if g_tool and not o_tool:
        errs.append(f"{name}: falta tool_use")
    if g_tool and o_tool:
        for k in g_tool["part"]:
            if k in ("id", "messageID", "sessionID", "snapshot", "metadata"):
                continue
            if k not in o_tool["part"]:
                errs.append(f"{name}: tool_use.part sin '{k}'")
        for k in ("status", "input"):
            if k not in o_tool["part"]["state"]:
                errs.append(f"{name}: tool_use.part.state sin '{k}'")
    g_fin = next((e for e in golden if e["type"] == "step_finish"), None)
    o_fin = next((e for e in events if e["type"] == "step_finish"), None)
    if g_fin and o_fin:
        for k in ("reason", "tokens"):
            if k not in o_fin["part"]:
                errs.append(f"{name}: step_finish.part sin '{k}'")
        for k in ("input", "output"):
            if k not in o_fin["part"].get("tokens", {}):
                errs.append(f"{name}: step_finish.part.tokens sin '{k}'")
    return errs


def check_request(name: str, rec: Path) -> list[str]:
    errs: list[str] = []
    gold = json.loads((GOLDEN / "soso-wire-4turn" / "peticion-01.json").read_text())
    reqs = sorted(rec.glob("peticion-*.json"))
    if not reqs:
        return [f"{name}: el mock no recibió peticiones"]
    first = json.loads(reqs[0].read_text())
    for k in gold:
        if k == "stream_options":  # solo con "stream": true
            continue
        if k not in first:
            errs.append(f"{name}: la petición no tiene '{k}'")
    ours = {t["function"]["name"] for t in first.get("tools", [])}
    want = {t["function"]["name"] for t in gold["tools"]} - {"skill"}  # skill solo si hay skills
    if not want <= ours:
        errs.append(f"{name}: faltan herramientas del golden (salvo skill): {sorted(want - ours)}")
    for t in first.get("tools", []):
        if t["type"] != "function" or "parameters" not in t["function"]:
            errs.append(f"{name}: herramienta mal formada: {t['function'].get('name')}")
    if len(reqs) > 1:
        msgs = json.loads(reqs[1].read_text())["messages"]
        asst = [m for m in msgs if m["role"] == "assistant" and m.get("tool_calls")]
        tool = [m for m in msgs if m["role"] == "tool"]
        if not asst or not tool:
            errs.append(f"{name}: la 2ª petición debe llevar assistant.tool_calls y role:tool")
        elif asst[0]["tool_calls"][0]["id"] != tool[0]["tool_call_id"]:
            errs.append(f"{name}: tool_call_id no coincide con la llamada")
    return errs


def main() -> int:
    if not BIN.is_file():
        print("falta binario; ejecutar ./build.sh", file=sys.stderr)
        return 2
    errs: list[str] = []
    names = [p.name for p in sorted(GOLDEN.iterdir()) if (p / "eventos.jsonl").exists()]
    for name in names:
        golden = [json.loads(l) for l in (GOLDEN / name / "eventos.jsonl").read_text().splitlines() if l.strip()]
        work = ROOT / "tests" / "out" / "ref" / name
        rc, events = run(name, work, work / "rec")
        if rc != 0:
            errs.append(f"{name}: exit {rc}")
        errs += check_events(name, events, golden)
        errs += check_request(name, work / "rec")
    if errs:
        print("\n".join(errs), file=sys.stderr)
        return 1
    print(f"diff_referencia OK ({len(names)} guiones: {', '.join(names)})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
