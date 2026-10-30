#!/usr/bin/env python3
"""Servidor HTTP mínimo para pruebas de opencode-sal (sin TLS, sin modelo real)."""
import socket
import threading

RESP = (
    b"HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nConnection: close\r\n\r\n"
    b"data: {\"choices\":[{\"message\":{\"content\":\"mock\"}}]}\n\n"
)


def serve(port: int) -> None:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    s.bind(("127.0.0.1", port))
    s.listen(1)
    conn, _ = s.accept()
    conn.recv(65536)
    conn.sendall(RESP)
    conn.close()
    s.close()


if __name__ == "__main__":
    serve(7422)
