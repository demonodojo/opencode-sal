---
name: opencode-sal-agente
description: >-
  Implementa el CLI opencode en Sal: run, sesiones, prompt de sistema, bucle
  de herramientas, cliente HTTP a soso-llm y eventos JSON (step_start,
  tool_use, text, step_finish). Usar al editar src/main.sal, agent_run, tools,
  parse, events, http, json, config, session o skills, o al alinear la salida
  con el ejecutor Rust runner.rs.
---

# Agente `opencode`

Binario `out/linux/bin/opencode` en el host y `out/bin/opencode` en el guest. Versión impresa: `opencode-sal 0.4.0` (`version_str` en `src/main.sal`). `Sal.toml` lleva la misma versión de paquete (`0.4.0`).

## CLI

```
opencode
opencode --version
opencode run [--format json] [--session ID] [--continue] [--max-turns N] PROMPT
opencode reinstalar
```

Sin argumentos entra en la sesión interactiva (`tui_loop` en `src/tui.sal`): banner, prompt `> `, cada línea llama a `run_once` con salida humana (`json_out == 2` en `src/events.sal`: líneas `tool <nombre>` y texto del asistente). Tras el primer mensaje, los turnos siguientes usan `--continue` vía `session_continue_prompt`. `exit`, `quit` o EOF (Ctrl-D) salen 0; línea vacía repite el prompt. Otro subcomando desconocido sale 2 con el uso en stderr.

`run` empaqueta flags en un entero (`scan_flags`): formato, `--continue` y `--max-turns` (default 40). `--session` por defecto es `default`. El prompt es el último argumento; si es `json` o contiene `--`, el prompt queda `hello`. Con menos de 3 argumentos el prompt también es `hello`.

`reinstalar` hace `spawn` de `/bin/soso-pkg` sin más argumentos.

## Un turno

`run_once` (`src/agent_run.sal`):

1. `step_start` si la salida es JSON.
2. Prompt de usuario, o `session_continue_prompt` si `--continue`.
3. `POST /v1/chat/completions` al puerto de `opencode.json`, cuerpo de `chat_completion_body`.
4. Mientras la respuesta contenga `tool_calls` o `function`, y el turno sea menor que `--max-turns`: despacha la herramienta, emite `tool_use` running y completed, y reenvía con `followup_tool_body`.
5. Si no hay herramienta: emite `text` (o `done` si el contenido sale vacío), `step_finish` con tokens 0/0, y guarda el cuerpo HTTP en la sesión.

`oc_error` existe en `src/events.sal` y el bucle no lo llama. Los eventos solo se escriben en stdout cuando `--format json` está activo. Una línea por evento, con `type` y `part`, compatible con el ejecutor Rust (`runner.rs`): `step_start`, `tool_use` (`callID`, `tool`, `state.status` = `running`|`completed`), `text`, `step_finish`.

## Modelo y prompt

| Dato | Origen |
|------|--------|
| Puerto | `7442` si `opencode.json` contiene el texto `:7442`; si no, `7422` |
| Modelo | fijo `soso-coder` |
| Sistema | `AGENTS.md`, o `You are opencode-sal on soso.` si el fichero está vacío |
| Skill | se concatena `.opencode/skills/soso-self-improvement/SKILL.md`, o si no `.claude/skills/soso-self-improvement/SKILL.md`, bajo el separador `--- skill ---` |

HTTP/1.1 a `127.0.0.1`, sin TLS, `stream: false`, `Connection: close`, cuerpo máximo de lectura 65536. `http_post` devuelve `""` si no conecta. El seguimiento de una herramienta es otro mensaje `user` con el texto `Tool <nombre> returned: <salida>`.

## Herramientas

`tool_dispatch` (`src/tools.sal`) acepta `read`, `write`, `edit`, `reemplazar_texto`, `grep`, `list`, `glob`, `bash`. Cualquier otro nombre devuelve `unsupported tool`.

| Nombre | Efecto |
|--------|--------|
| `read` | Contenido del fichero (`path`, `file_path` o `directory`) |
| `write` | Escribe el cuerpo HTTP entero en `path` |
| `edit`, `reemplazar_texto` | Primera aparición de `old_string`/`oldText` por `new_string`/`newText` |
| `grep` | `match` o vacío, según `str_contains` del fichero |
| `list` | Primer nombre del directorio que no es `.` ni `..` |
| `glob` | Ese listado si contiene el patrón; si no, vacío |
| `bash` | `spawn` de `/bin/sosh` con el comando; devuelve `started` |

El nombre se elige por subcadenas, en este orden: `reemplazar_texto`, `edit`, `glob`, `list`, `bash`, `grep`, `write`, `read`. Un cuerpo que mencione dos nombres se queda con el que aparece antes en esa lista.

`extract_quoted_after` busca el marcador literal (`path":"`, `old_string":"`, `command":"`, …) y corta en la siguiente comilla. No interpreta `\"`. Un argumento JSON anidado y escapado no rellena `path`. Las pruebas del mock comprueban los eventos, no que el path escapado se haya leído.

## Sesión

`/var/opencode/sessions/<id>/state.json`. `--continue` antepone `Continue prior session.` y hasta 512 caracteres del estado previo. `session_save` guarda la última respuesta HTTP, no un historial de mensajes.
