#!/usr/bin/env python3
"""Comprueba las rutas de skills y su prioridad con un proyecto y HOME aislados."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

with tempfile.TemporaryDirectory(prefix="supercoder-skills-") as tmp:
    root = Path(tmp) / "project"
    work = root / "nested"
    home = Path(tmp) / "home"
    work.mkdir(parents=True)
    (root / ".git").mkdir()

    def skill(base, folder, name, description):
        path = base / folder / "SKILL.md"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(f"---\nname: {name}\ndescription: {description}\n---\nInstructions.\n")

    skill(work / ".agents/skills", "project", "priority", "project agents wins")
    skill(work / ".supercoder/skills", "project", "priority", "project supercoder loses")
    skill(root / ".agents/skills", "parent", "priority", "parent loses")
    skill(home / ".agents/skills", "user", "priority", "user loses")
    skill(home / ".agents/skills", "user", "user-priority", "user agents wins")
    skill(home / ".supercoder/skills", "user", "user-priority", "user supercoder loses")
    env = dict(os.environ, HOME=str(home), SUPERCODER_HOME=str(home / ".supercoder"))
    result = subprocess.run([sys.argv[1], "skills"], cwd=work, env=env, text=True, capture_output=True, check=True)
    assert "project agents wins" in result.stdout, result.stdout
    assert "user agents wins" in result.stdout, result.stdout
    assert "loses" not in result.stdout, result.stdout
print("OK skills: .agents en proyecto y usuario, con prioridad")
