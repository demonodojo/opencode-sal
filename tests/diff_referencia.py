#!/usr/bin/env python3
"""Compara salida de supercoder-sal con golden (normalizando ids y timestamps)."""
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
GOLDEN = Path(__file__).resolve().parent / "golden"
GUIONES = Path(__file__).resolve().parent / "guiones"
BIN = ROOT / "out" / "linux" / "bin" / "supercoder"


def normalize_json_line(line: str) -> str:
    line = line.strip()
    if not line:
        return line
    try:
        obj = json.loads(line)
    except json.JSONDecodeError:
        return re.sub(r"ses_[A-Za-z0-9]+", "ses_NORMALIZED", line)
    return json.dumps(normalize_obj(obj), sort_keys=True, ensure_ascii=False)


def normalize_obj(obj):
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if k in ("timestamp", "snapshot") and isinstance(v, (int, str)):
                out[k] = "NORMALIZED"
            elif k in ("sessionID", "messageID", "id", "callID") and isinstance(v, str):
                out[k] = re.sub(r"(ses_|msg_|prt_|call_)[A-Za-z0-9]+", r"\1N", v)
            elif k == "Today's date:":
                out[k] = "NORMALIZED"
            else:
                out[k] = normalize_obj(v)
        if "content" in out and isinstance(out["content"], str):
            out["content"] = re.sub(
                r"Today's date: [^\n]+",
                "Today's date: NORMALIZED",
                out["content"],
            )
            out["content"] = re.sub(r"/tmp/[^\s\"']+", "/tmp/WORK", out["content"])
        return out
    if isinstance(obj, list):
        return [normalize_obj(x) for x in obj]
    if isinstance(obj, str):
        s = re.sub(r"ses_[A-Za-z0-9]+", "ses_N", obj)
        s = re.sub(r"msg_[A-Za-z0-9]+", "msg_N", s)
        s = re.sub(r"prt_[A-Za-z0-9]+", "prt_N", s)
        return s
    return obj


def normalize_request_text(text: str) -> str:
    try:
        obj = json.loads(text)
    except json.JSONDecodeError:
        return text
    return json.dumps(normalize_obj(obj), indent=1, ensure_ascii=False) + "\n"


def diff_files(got: Path, want: Path, normalizer) -> list[str]:
    if not want.exists():
        return [f"golden ausente: {want}"]
    if not got.exists():
        return [f"salida ausente: {got}"]
    g = normalizer(got.read_text(encoding="utf-8"))
    w = normalizer(want.read_text(encoding="utf-8"))
    if g == w:
        return []
    return [f"diff {want.name}: got {len(g)} bytes want {len(w)} bytes"]


def run_sal(guion: str, port: int, workdir: Path, out_dir: Path) -> int:
    out_dir.mkdir(parents=True, exist_ok=True)
    env = {
        **dict(__import__("os").environ),
        "RECORD_DIR": str(out_dir),
    }
    mock = subprocess.Popen(
        [sys.executable, str(ROOT / "tests" / "mock_llm.py"), str(port), str(GUIONES / guion)],
        cwd=ROOT,
    )
    try:
        import time

        time.sleep(0.4)
        config = workdir / "supercoder.json"
        if not config.exists():
            config.write_text(
                json.dumps(
                    {
                        "$schema": "https://opencode.ai/config.json",
                        "model": "soso/soso-coder",
                        "provider": {
                            "soso": {
                                "options": {
                                    "baseURL": f"http://127.0.0.1:{port}/v1",
                                    "apiKey": "test",
                                },
                                "models": {
                                    "soso-coder": {
                                        "limit": {"context": 32768, "output": 2048}
                                    }
                                },
                            }
                        },
                        "agent": {"title": {"disable": True}},
                    },
                    indent=2,
                ),
                encoding="utf-8",
            )
        proc = subprocess.run(
            [
                str(BIN),
                "run",
                "--format",
                "json",
                "--agent",
                "soso-improve",
                "lee /tmp/oc-fixture.txt",
            ],
            cwd=workdir,
            env=env,
            capture_output=True,
            text=True,
        )
        (out_dir / "eventos.jsonl").write_text(proc.stdout, encoding="utf-8")
        (out_dir / "stderr.txt").write_text(proc.stderr, encoding="utf-8")
        return proc.returncode
    finally:
        mock.terminate()
        mock.wait(timeout=5)


def compare_guion(name: str) -> list[str]:
    golden_dir = GOLDEN / name
    if not golden_dir.exists():
        return [f"sin golden para {name} (ejecutar capturar_referencia.sh)"]
    work = ROOT / "tests" / "work" / name
    work.mkdir(parents=True, exist_ok=True)
    got_dir = ROOT / "tests" / "out" / name
    rc = run_sal(f"{name}.json", 7422 + hash(name) % 100, work, got_dir)
    errs: list[str] = []
    if rc != 0:
        errs.append(f"{name}: exit {rc}")
    for pat in sorted(golden_dir.glob("peticion-*.json")):
        n = pat.name
        errs.extend(
            diff_files(got_dir / n, pat, normalize_request_text)
        )
    ev_g = golden_dir / "eventos.jsonl"
    ev_o = got_dir / "eventos.jsonl"
    if ev_g.exists() and ev_o.exists():
        g_lines = [normalize_json_line(l) for l in ev_g.read_text().splitlines() if l.strip()]
        o_lines = [normalize_json_line(l) for l in ev_o.read_text().splitlines() if l.strip()]
        if g_lines != o_lines:
            errs.append(f"{name}: eventos.jsonl difiere ({len(o_lines)} vs {len(g_lines)} líneas)")
    return errs


def main() -> int:
    if not BIN.is_file():
        print("falta binario; ejecutar ./build.sh", file=sys.stderr)
        return 2
    guiones = [p.stem for p in GUIONES.glob("*.json")]
    all_errs: list[str] = []
    for g in guiones:
        all_errs.extend(compare_guion(g))
    if all_errs:
        for e in all_errs:
            print(e, file=sys.stderr)
        return 1
    print(f"diff_referencia OK ({len(guiones)} guiones)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
