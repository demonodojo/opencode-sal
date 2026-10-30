# Skills de opencode-sal

Un solo directorio real, `.claude/skills/`. Las otras dos rutas son enlaces simbólicos a él:

| Ruta | Uso |
|------|-----|
| `.claude/skills/` | Directorio real |
| `.cursor/skills/` | Cursor → `../.claude/skills` |
| `.agents/skills/` | Otros agentes → `../.claude/skills` |

Editar una vez. Sustituir el enlace por un directorio crea una copia que hay que mantener aparte. Comprobarlo con `file .cursor/skills`.

| Skill | Cuándo |
|-------|--------|
| `opencode-sal-dev` | Compilar, probar, layout, empaquetado |
| `opencode-sal-agente` | CLI `opencode`, bucle, herramientas, eventos JSON, HTTP |
| `opencode-sal-campana` | `soso-improve-sal campana` |

Estas skills son para quien modifica el repo. El proceso `opencode` no las carga: su prompt lee `AGENTS.md` del directorio de trabajo y, si existe, `.opencode/skills/soso-self-improvement/SKILL.md` o `.claude/skills/soso-self-improvement/SKILL.md`.
