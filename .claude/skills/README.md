# Skills de supercoder-sal

Un solo directorio real, `.claude/skills/`. Las otras dos rutas son enlaces simbólicos a él:

| Ruta | Uso |
|------|-----|
| `.claude/skills/` | Directorio real |
| `.cursor/skills/` | Cursor → `../.claude/skills` |
| `.agents/skills/` | Otros agentes → `../.claude/skills` |

Editar una vez. Sustituir el enlace por un directorio crea una copia que hay que mantener aparte. Comprobarlo con `file .cursor/skills`.

| Skill | Cuándo |
|-------|--------|
| `supercoder-sal-dev` | Compilar, probar, layout, empaquetado |
| `supercoder-sal-release` | Subir versión, tag `vX.Y.Z`, GitHub Release y artefactos |
| `supercoder-sal-agente` | CLI `supercoder`, bucle, herramientas, eventos JSON, HTTP |
| `supercoder-sal-campana` | `soso-improve-sal campana` |

Estas skills son para quien modifica el repo. El proceso `supercoder` no las carga: su prompt lee `AGENTS.md` del directorio de trabajo y, si existe, `.supercoder/skills/soso-self-improvement/SKILL.md` o `.claude/skills/soso-self-improvement/SKILL.md`.
