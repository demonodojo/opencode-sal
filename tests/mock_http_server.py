#!/usr/bin/env python3
"""Mock soso-llm: read /tmp/oc-fixture.txt, luego respuesta final."""
import socket
import sys

TOOL = (
    b"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n"
    b'{"choices":[{"message":{"role":"assistant","tool_calls":[{"id":"c1","function":{"name":"read","arguments":"{\\"path\\":\\"/tmp/oc-fixture.txt\\"}"}}]}}]}'
)
FINAL = (
    b"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n"
    b'{"choices":[{"message":{"role":"assistant","content":"terminado"}}]}'
)
EDIT = (
    b"HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nConnection: close\r\n\r\n"
    b'{"choices":[{"message":{"role":"assistant","tool_calls":[{"id":"c2","function":{"name":"edit","arguments":"{\\"path\\":\\"/tmp/oc-fixture.txt\\",\\"old_string\\":\\"fixture\\",\\"new_string\\":\\"patched\\"}"}}]}}]}'
)


def serve(port: int, mode: str) -> None:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", port))
    s.listen(5)
    seq = [TOOL, EDIT, FINAL] if mode == "edit" else [TOOL, FINAL]
    for payload in seq:
        conn, _ = s.accept()
        conn.recv(65536)
        conn.sendall(payload)
        conn.close()
    s.close()


if __name__ == "__main__":
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 7422
    mode = sys.argv[2] if len(sys.argv) > 2 else "read"
    serve(port, mode)
