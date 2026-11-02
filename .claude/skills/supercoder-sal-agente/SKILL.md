---
name: supercoder-sal-agente
description: >-
  Implementa el CLI supercoder en Sal: run, sesiones, prompt de sistema, bucle
  de herramientas con esquemas JSON, proveedores (OpenAI/soso-llm y claude -p),
  permisos, agentes y subagentes, imágenes, compactación, streaming y eventos
  JSON (step_start, tool_use, text, step_finish...). Usar al editar src/main.sal,
  src/agent, src/provider, src/tools, src/perm.sal, src/agents.sal, events,
  config, session o skills, o al alinear la salida con el ejecutor Rust runner.rs.
---

# Agente `supercoder`

Binario `out/linux/bin/supercoder` en el host y `out/bin/supercoder` en el guest. Versión impresa: `supercoder-sal 0.5.0` (`version_str` en `src/main.sal`; `Sal.toml` lleva la misma). Las utilidades genéricas (JSON, regex, glob, HTTP, procesos, base64, frontmatter) viven en el repo hermano `salkit` y se importan como `salkit/…`.

## CLI

```
supercoder                                  # TUI
supercoder run [--format json] [--session ID] [--continue] [--max-turns N]
               [--model M] [--agent A] [--interactive] [--yes] [--depth N]
               [--file RUTA]... [--] PROMPT
supercoder session list
supercoder agents
supercoder --version | reinstalar
```

`--depth` lo pone el padre al lanzar un subagente (no tiene `task`). El prompt es el resto de argumentos posicionales o lo que sigue a `--`.

## Estructura de `src/`

| Fichero | Contenido |
|---------|-----------|
| `main.sal` | CLI |
| `agent/run.sal` | `run_agent`: prepara ctx (config, agente, sesión, prompt, herramientas) y `run_claude` |
| `agent/loop.sal` | Bucle: compactar, petición (reintentos 429 y 400), llamadas a herramientas, tokens, guarda la sesión |
| `agent/ctx.sal` | Contexto: un vec con ranuras y accesores `ctx_*` |
| `agent/messages.sal` | Constructores de mensajes OpenAI y llamadas |
| `agent/prompt.sal` | Prompt de sistema: base + agente + AGENTS.md/CLAUDE.md + skills + entorno |
| `agent/compact.sal` | 56 mensajes o `context_chars`: recorta salidas viejas y luego resume |
| `agent/attach.sal`, `agent/vision.sal` | `--file`, `@ruta`, imágenes (visión propia o `vision_model`) |
| `agent/child.sal` | Proceso hijo con pipes (task y TUI) |
| `provider/openai.sal` | `/v1/chat/completions` con `tools`, Bearer, streaming SSE opcional |
| `provider/claude.sal` | `claude -p` |
| `tools/*.sal` | `read write edit list glob grep bash todo task`; `names.sal` alias; `registry.sal` esquemas, validación y despacho |
| `perm.sal` | allow/ask/deny, `permission_request`, grants «always» |
| `agents.sal` | build, plan, general, explore + `.supercoder|.opencode|.claude/agents/*.md` |
| `skills.sal` | `SKILL.md` descubiertos y herramienta `skill` |
| `events.sal`, `session.sal`, `config.sal`, `tui.sal`, `util.sal` | Eventos, sesiones, configuración, TUI, rutas y fechas |

## Un turno

`agent_loop`: `step_start` → `compact_if_needed` → petición (`chat_once`: 429 espera 5 s hasta 24 veces; 400 devuelve el error al modelo hasta 5 veces) → texto y/o `tool_calls`. Cada llamada se valida (JSON, parámetros obligatorios con alias, herramienta permitida, permisos), se ejecuta y vuelve como mensaje `role:"tool"` con `tool_call_id`. Termina sin llamadas (`step_finish` reason `stop`), por error (1) o al agotar `--max-turns` (2). La sesión se guarda en cada iteración en `$SUPERCODER_HOME/sessions/<id>/messages.json` (+ `todos.json`, `grants.txt`).

## Eventos (`--format json`)

Una línea por evento con `type`, `timestamp`, `sessionID`, `part`. Compatibles con `runner.rs`: `step_start`, `tool_use` (`state.status` running|completed|error, `input`, `output`/`error`, `title`), `text`, `step_finish` (`tokens.input/output` reales), `error` (`error.data.message`). Extra (el ejecutor los ignora): `text_delta`, `permission_request` (`id, callID, tool, title, input`; respuesta por stdin `{"type":"permission_reply","id":..,"reply":"once|always|reject"}`), `todo`, `subagent` (`callID`, `event` = evento original del hijo).

## Permisos

Reglas de `"permission"` en `supercoder.json` y del agente (`allow|ask|deny`; en un mapa de patrones gana la última que casa). Categorías: `read`, `edit` (write/edit), `bash`, `external_directory`, `task`, `skill`. Por defecto: `bash` es `ask` salvo comandos de lectura sin metacaracteres; rutas fuera del cwd `ask`. `ask` → `--yes` aprueba; `--interactive` pregunta (JSON por stdin o línea en stderr); si no, rechazo con mensaje al modelo. La campaña pasa `--yes`.

## Subagentes

`task {description, prompt, subagent_type}` lanza `supercoder run --format json --agent T --session <padre>-task-<callID> --depth 1 …`, reemite sus eventos como `subagent`, reenvía sus `permission_request` al cliente del padre, suma tokens y devuelve el último `text`. Los subagentes no tienen `task`.

## Imágenes

`read` de una imagen y `--file`/`@ruta`: con `"vision": true` van como `image_url` (data URL base64, máx. 5 MB); sin visión nunca (soso-llm da 422): `"vision_model"` describe la imagen y la descripción sustituye a la imagen; sin él, aviso de texto.

## Configuración (`supercoder.json`)

`model`, `shell`, `binary`, `vision_model`, `permission`, `models.<id>`: `provider` (`claude`), `host`, `port`, `token`/`token_env`/`token_file` (si no, `$SOSO_LLM_API_KEY`), `max_tokens`, `timeout_ms`, `context_chars`, `vision`, `stream`.

## Convenciones de Sal que importan aquí

Sin structs multicampo: asas `vec` y accesores. Cada función con efectos propios los declara. Los nombres de módulos importados se aplanan: prefijar. Las cadenas se mueven al asignar (copiar con `str_slice(s, 0, str_len(s))`). `on` y `from` están reservadas. `{{`/`}}` para llaves literales. La memoria no se libera: acumular con `x = x + …`.

## Pruebas

`tests/sal/test_*.sal` (unitarios) y `OC_SAL_E2E=1 tests/probar_sal.sh` contra `tests/mock_llm.py` con guiones en `tests/guiones/` (herramientas, permisos interactivos con `tests/perm_client.py`, subagentes, imágenes, streaming, compactación, claude falso). Si se toca el protocolo con el modelo, comprobar también la forma de la petición (`RECORD_DIR`) y `tests/diff_referencia.py`.
