#!/usr/bin/env python3
"""Cliente de permisos para las pruebas: lanza `supercoder run --interactive` y contesta a cada
permission_request con la siguiente respuesta de la lista (once|always|reject)."""
import json
import subprocess
import sys

binary, replies, session = sys.argv[1], sys.argv[2].split(","), sys.argv[3]
p = subprocess.Popen(
    [binary, "run", "--format", "json", "--interactive", "--session", session, "go"],
    stdin=subprocess.PIPE, stdout=subprocess.PIPE, text=True,
)
reqs, events = [], []
for line in p.stdout:
    e = json.loads(line)
    events.append(e)
    if e["type"] == "permission_request":
        reply = replies[len(reqs)] if len(reqs) < len(replies) else "reject"
        reqs.append(e["part"])
        p.stdin.write(json.dumps({"type": "permission_reply", "id": e["part"]["id"], "reply": reply}) + "\n")
        p.stdin.flush()
p.wait()
print(json.dumps({
    "requests": len(reqs),
    "tools": [[e["part"]["tool"], e["part"]["state"]["status"]] for e in events if e["type"] == "tool_use" and e["part"]["state"]["status"] != "running"],
    "last": events[-1]["type"],
}))
