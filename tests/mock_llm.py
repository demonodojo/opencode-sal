#!/usr/bin/env python3
"""Mock soso-llm con SSE guionizado; graba peticiones si RECORD_DIR está definido."""
from __future__ import annotations

import json
import os
import socket
import sys
import threading
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path
from typing import Any


def _sse_chunk(obj: dict[str, Any]) -> bytes:
    return ("data: " + json.dumps(obj, separators=(",", ":")) + "\n\n").encode()


def _tool_call_events(call_index: int, name: str, arguments: dict[str, Any], fragments: bool = False) -> list[bytes]:
    args_str = json.dumps(arguments, separators=(",", ":"))
    if fragments:
        # El nombre y el id llegan primero; los argumentos en tres trozos, como hace OpenAI.
        third = max(1, len(args_str) // 3)
        parts = [args_str[:third], args_str[third : 2 * third], args_str[2 * third :]]
        frames: list[dict[str, Any]] = [
            {"choices": [{"index": 0, "delta": {"role": "assistant", "tool_calls": [{"index": 0, "id": f"call_{call_index}", "type": "function", "function": {"name": name, "arguments": ""}}]}, "finish_reason": None}]}
        ]
        for p in parts:
            frames.append({"choices": [{"index": 0, "delta": {"tool_calls": [{"index": 0, "function": {"arguments": p}}]}, "finish_reason": None}]})
        frames.append({"choices": [{"index": 0, "delta": {}, "finish_reason": "tool_calls"}]})
        frames.append({"choices": [], "usage": {"prompt_tokens": 50, "completion_tokens": 7, "total_tokens": 57}})
        return [_sse_chunk(f) for f in frames] + [b"data: [DONE]\n\n"]
    chunks = [
        {
            "id": "chatcmpl-mock",
            "object": "chat.completion.chunk",
            "choices": [
                {
                    "index": 0,
                    "delta": {
                        "role": "assistant",
                        "tool_calls": [
                            {
                                "index": 0,
                                "id": f"call_{call_index}",
                                "type": "function",
                                "function": {"name": name, "arguments": args_str},
                            }
                        ],
                    },
                    "finish_reason": None,
                }
            ],
        },
        {
            "id": "chatcmpl-mock",
            "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {}, "finish_reason": "tool_calls"}],
        },
    ]
    out = [_sse_chunk(c) for c in chunks]
    out.append(b"data: [DONE]\n\n")
    return out


def _content_events(text: str, usage: dict[str, int] | None = None, deltas: list[str] | None = None) -> list[bytes]:
    pieces = deltas if deltas else [text]
    chunks: list[dict[str, Any]] = [
        {
            "id": "chatcmpl-mock",
            "object": "chat.completion.chunk",
            "choices": [
                {
                    "index": 0,
                    "delta": ({"role": "assistant", "content": piece} if i == 0 else {"content": piece}),
                    "finish_reason": None,
                }
            ],
        }
        for i, piece in enumerate(pieces)
    ] + [
        {
            "id": "chatcmpl-mock",
            "object": "chat.completion.chunk",
            "choices": [{"index": 0, "delta": {}, "finish_reason": "stop"}],
        },
    ]
    if usage:
        chunks.insert(-1, {"id": "chatcmpl-mock", "object": "chat.completion.chunk", "usage": usage})
    out = [_sse_chunk(c) for c in chunks]
    out.append(b"data: [DONE]\n\n")
    return out


def _json_tool_call(call_index: int, name: str, arguments: dict[str, Any]) -> dict[str, Any]:
    return {
        "id": "chatcmpl-mock",
        "object": "chat.completion",
        "choices": [
            {
                "index": 0,
                "message": {
                    "role": "assistant",
                    "content": None,
                    "tool_calls": [
                        {
                            "id": f"call_{call_index}",
                            "type": "function",
                            "function": {"name": name, "arguments": json.dumps(arguments, separators=(",", ":"))},
                        }
                    ],
                },
                "finish_reason": "tool_calls",
            }
        ],
        "usage": {"prompt_tokens": 50, "completion_tokens": 7, "total_tokens": 57},
    }


def _json_content(text: str, usage: dict[str, int] | None = None) -> dict[str, Any]:
    return {
        "id": "chatcmpl-mock",
        "object": "chat.completion",
        "choices": [
            {"index": 0, "message": {"role": "assistant", "content": text}, "finish_reason": "stop"}
        ],
        "usage": usage or {"prompt_tokens": 60, "completion_tokens": 4, "total_tokens": 64},
    }


def load_guion(path: Path) -> dict[str, Any]:
    with path.open(encoding="utf-8") as f:
        return json.load(f)


def steps_to_responses(steps: list[dict[str, Any]], call_counter: list[int]) -> list[dict[str, Any]]:
    seq: list[dict[str, Any]] = []
    for step in steps:
        st = step.get("type", "tool_calls")
        if st == "tool_calls":
            call_counter[0] += 1
            name = step["name"]
            args = step.get("arguments", step.get("input", {}))
            seq.append(
                {
                    "sse": _tool_call_events(call_counter[0], name, args, bool(step.get("fragments"))),
                    "json": _json_tool_call(call_counter[0], name, args),
                }
            )
        elif st == "content":
            usage = step.get("usage")
            deltas = step.get("deltas")
            text = "".join(deltas) if deltas else step.get("text", step.get("content", "ok"))
            seq.append({"sse": _content_events(text, usage, deltas), "json": _json_content(text, usage)})
        elif st == "error":
            seq.append({"status": step.get("status", 400), "json": {"error": {"message": step.get("message", "mock error")}}})
        elif st == "raw_sse":
            seq.append({"sse": [s.encode() if isinstance(s, str) else s for s in step["frames"]], "json": None})
        else:
            raise ValueError(f"tipo de paso desconocido: {st}")
    return seq


class MockState:
    def __init__(self, guion: dict[str, Any], record_dir: Path | None) -> None:
        self.responses: list[dict[str, Any]] = steps_to_responses(guion.get("steps", []), [0])
        self.i = 0
        self.record_dir = record_dir
        self.req_n = 0
        self.lock = threading.Lock()


def make_handler(state: MockState):
    class H(BaseHTTPRequestHandler):
        def log_message(self, fmt: str, *args: Any) -> None:
            pass

        def do_POST(self) -> None:
            if self.path.split("?")[0] not in ("/v1/chat/completions", "/chat/completions"):
                self.send_error(404)
                return
            length = int(self.headers.get("Content-Length", "0"))
            body = self.rfile.read(length)
            headers_text = "\n".join(f"{k}: {v}" for k, v in self.headers.items())
            with state.lock:
                state.req_n += 1
                n = state.req_n
                if state.record_dir:
                    state.record_dir.mkdir(parents=True, exist_ok=True)
                    (state.record_dir / f"cabeceras-{n:02d}.txt").write_text(
                        f"{self.command} {self.path}\n{headers_text}\n\n", encoding="utf-8"
                    )
                    try:
                        parsed = json.loads(body)
                        (state.record_dir / f"peticion-{n:02d}.json").write_text(
                            json.dumps(parsed, indent=1, ensure_ascii=False) + "\n", encoding="utf-8"
                        )
                    except json.JSONDecodeError:
                        (state.record_dir / f"peticion-{n:02d}.raw").write_bytes(body)

                if state.i >= len(state.responses):
                    step = {"sse": _content_events("mock: sin más pasos en el guion"), "json": _json_content("mock: sin más pasos en el guion")}
                else:
                    step = state.responses[state.i]
                    state.i += 1

            try:
                req = json.loads(body)
            except json.JSONDecodeError:
                req = {}
            if "status" in step:
                payload = json.dumps(step["json"]).encode()
                hdrs = (
                    f"HTTP/1.1 {step['status']} Mock\r\nContent-Type: application/json\r\n"
                    f"Content-Length: {len(payload)}\r\nConnection: close\r\n\r\n"
                )
                self.wfile.write(hdrs.encode() + payload)
            elif req.get("stream") is False and step.get("json") is not None:
                payload = json.dumps(step["json"]).encode()
                hdrs = (
                    "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n"
                    f"Content-Length: {len(payload)}\r\nConnection: close\r\n\r\n"
                )
                self.wfile.write(hdrs.encode() + payload)
            else:
                hdrs = (
                    "HTTP/1.1 200 OK\r\n"
                    "Content-Type: text/event-stream\r\n"
                    "Cache-Control: no-cache\r\n"
                    "Connection: close\r\n\r\n"
                )
                self.wfile.write(hdrs.encode() + b"".join(step["sse"]))
            self.wfile.flush()

    return H


def serve(port: int, guion_path: Path, record_dir: Path | None) -> None:
    guion = load_guion(guion_path)
    state = MockState(guion, record_dir)
    httpd = HTTPServer(("127.0.0.1", port), make_handler(state))
    httpd.serve_forever()


def main() -> None:
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 7422
    guion = Path(sys.argv[2]) if len(sys.argv) > 2 else Path(__file__).parent / "guiones" / "read_then_stop.json"
    record = os.environ.get("RECORD_DIR")
    record_dir = Path(record) if record else None
    serve(port, guion, record_dir)


if __name__ == "__main__":
    main()
