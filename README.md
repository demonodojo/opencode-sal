# supercoder-sal

Reimplementación de OpenCode en Sal para soso ([D12](https://github.com/demonodojo/soso/blob/main/docs/self-improvement/DECISIONES.md)).

## Build

```bash
./build.sh
```

Genera:

- `out/bin/*` — ELF **soso** (guest; requiere SDK: `cargo xtask sal-build --cross-only` en repo `soso`).
- `out/linux/bin/*` — binarios **Linux** nativos (`sal build --target linux`); misma fuente, `import "io/…"`, con shim de syscalls en el runtime Sal.

Requiere `sal` en PATH (repo hermano `../sal`) y el repo hermano [`../salkit`](https://github.com/demonodojo/salkit) (JSON, regex, glob, HTTP, procesos…). `build.sh` ejecuta `sal install`, que enlaza en `sal_modules/` la librería estándar `io` y `salkit` según [`Sal.toml`](Sal.toml).

## Instalación en soso

Desde el monorepo soso:

```bash
cargo xtask pkg-pack supercoder-sal
soso-pkg instalar supercoder-sal
```

## Comandos

- `supercoder` — TUI (logo, sesión y compositor, como OpenCode); `exit`/`quit`/EOF para salir; el primer Ctrl-C cancela el turno en marcha (o pide confirmación si la TUI está parada) y el segundo sale. Ctrl-V pega una imagen del portapapeles (se ve como `[Image]` y el retroceso quita la última); sin portapapeles gráfico (soso), escribe o pega la ruta de la imagen y pulsa Intro, o menciónala con `@ruta` en el mensaje. PgUp/PgDn recorren el historial. Cada turno corre en un proceso `supercoder run` aparte y los permisos se preguntan en línea (`[s]i / [a]siempre / [N]o`).
- `supercoder --version` (0.5.0)
- `supercoder run [opciones] <prompt>` — agente de código con herramientas, historial real, permisos, subagentes e imágenes (ver abajo)
- `supercoder session list` — sesiones guardadas
- `supercoder agents` — agentes disponibles
- `supercoder skills` — skills descubiertos (proyecto y usuario)
- `supercoder tool NOMBRE JSON [--yes]` — ejecuta una herramienta sin modelo (depuración)
- `soso-improve-sal campana <dir>` — coordinador (captura, diez pasos, validación); lanza `supercoder run --format json --yes`
- `supercoder reinstalar` — reinstala vía `soso-pkg` (borrador)

### `supercoder run`

| Opción | Efecto |
|--------|--------|
| `--format json` | Eventos JSON por líneas (si no, solo el texto final) |
| `--session ID` / `--continue` | Sesión (por defecto `default`); `--continue` recarga el historial |
| `--max-turns N` | Vueltas del bucle (por defecto 60) |
| `--model M` / `-m M` | Modelo (`supercoder.json`, `claude:<alias>`) |
| `--agent NOMBRE` | Agente (`build`, `plan`, `general`, `explore` o uno propio) |
| `--interactive` | Pregunta los permisos `ask` al cliente (evento `permission_request`, respuesta por stdin) |
| `--yes` | Aprueba sin preguntar los permisos `ask` |
| `--osc7501` | Con `--format json`, emite los informes OSC 7501 por stderr (lo usa la TUI) |
| `--file RUTA` | Adjunta un fichero o una imagen (repetible); también `@ruta` en el prompt |
| `--` | Lo que sigue es el prompt |

El historial completo se guarda en `$SUPERCODER_HOME/sessions/<id>/messages.json` (por defecto `~/.local/share/supercoder`, `/var/supercoder` en soso), junto con las tareas (`todos.json`) y los permisos concedidos con «siempre» (`grants.txt`).

### Herramientas

`read` (líneas numeradas, directorios, imágenes; si el fichero no existe sugiere nombres parecidos), `write`, `edit` (texto exacto, tolera la sangría y los finales CRLF, `replaceAll`; devuelve un fragmento del resultado y, si falla, dónde aparece la primera línea), `multiedit` (varias sustituciones atómicas en un fichero), `list`, `glob`, `grep` (regex o literal, `include`, `ignoreCase`, `context`), `bash` (timeout, salida recortada; un proceso en segundo plano no bloquea la orden), `todowrite`/`todoread`, `skill` y `task` (subagentes). Los esquemas JSON se envían al modelo y los argumentos se validan; los errores vuelven al modelo para que corrija.

### Skills

Un skill es una carpeta con un `SKILL.md` (frontmatter `name`, `description`, y opcionalmente `disable-model-invocation: true`; admite `description: >-` y `|`). Se buscan, y gana el primero con un nombre dado, en:

1. el directorio de trabajo y sus ascendientes hasta la raíz del repositorio: `.agents/skills`, `.supercoder/skills`, `.opencode/skills`, `.claude/skills`;
2. el directorio del usuario: `~/.agents/skills`, `~/.supercoder/skills`, `~/.config/opencode/skills`, `~/.claude/skills` (se siguen los enlaces simbólicos).

El prompt de sistema lista cada skill con su descripción (recortada) y el modelo lo carga con la herramienta `skill` antes de empezar la tarea: recibe el cuerpo, el directorio base y los ficheros que lo acompañan, que puede leer sin pedir permiso. El usuario también puede invocar uno escribiendo `/nombre argumentos` al principio del prompt (`$ARGUMENTS` se sustituye en el cuerpo). `supercoder skills` los lista; las reglas `permission.skill` permiten `allow`/`ask`/`deny` por nombre.

## Permisos

```json
{ "permission": { "edit": "allow", "bash": { "git status*": "allow", "rm *": "deny", "*": "ask" }, "external_directory": "ask" } }
```

Valores `allow`, `ask`, `deny`; en un objeto de patrones gana la última regla que casa. Por defecto: leer y editar `allow`, `bash` solo `allow` para comandos de lectura (`ls`, `git status`…), rutas fuera del directorio de trabajo `ask`. Sin cliente (`--interactive`) ni `--yes`, un `ask` se rechaza con un mensaje para el modelo.

### Agentes y subagentes

Integrados: `build` (todo), `plan` (solo lectura), `general` y `explore` (subagentes). Propios en `.supercoder/agents/NOMBRE.md`, `.opencode/agents/NOMBRE.md` o `.claude/agents/NOMBRE.md` con frontmatter (`description`, `mode: primary|subagent|all`, `model`, `tools`, `permission`) y el prompt en el cuerpo. La herramienta `task` lanza un subagente como proceso hijo (profundidad 1); sus eventos llegan al cliente anidados como `subagent` y sus permisos se reenvían.

### Imágenes

Un modelo con `"vision": true` recibe las imágenes como partes `image_url`. Los demás nunca las reciben (soso-llm responde 422): si hay `"vision_model": "<id>"` en `supercoder.json`, ese modelo las describe y la descripción sustituye a la imagen.

### Contexto y streaming

Antes de cada petición se compacta el historial si pasa de 56 mensajes o de `"context_chars"` (recorta salidas antiguas y, si no basta, las resume con el modelo). `"stream": true` en un modelo usa SSE y emite eventos `text_delta`.

### Estado en el terminal (OSC 7501)

El protocolo [OSC 7501](https://gist.github.com/mitchellh/7acae3abd8355c1c00287d67e96c913a) (Program Status Protocol) permite que el terminal sepa qué hace el agente y avise cuando necesita algo. `supercoder run` escribe un informe por stderr antes de cada paso (`state=working:app=supercoder:msg=<base64>`), al pedir un permiso (`state=blocked:kind=permission`) y al terminar (`done` o `error`), de modo que la pestaña o el panel del terminal muestra el estado aunque esté en segundo plano. La TUI informa además `state=idle` al arrancar, para que el terminal (p. ej. Herdr) la reconozca como agente antes del primer turno; después de cada turno no lo repite, para no pisar el `done` del hijo.

Se activa cuando `$TERM` está definido y no es `dumb`; se desactiva con `SUPERCODER_OSC7501=0`. Con `--format json` no se emite salvo que se pase `--osc7501` (la TUI lo hace para el proceso hijo de cada turno), y los subagentes nunca informan. No se envía la consulta `OSC 7501;?` porque su respuesta llegaría por stdin junto con la del usuario.

### Eventos `--format json`

Una línea por evento, con `timestamp` y `sessionID`. Compatibles con el ejecutor Rust (`runner.rs`): `step_start`, `tool_use` (`state.status` running/completed/error con `input`, `output`, `title`), `text`, `step_finish` (`tokens`), `error` (`error.data.message`). Ampliados (el ejecutor los ignora): `text_delta`, `permission_request`, `todo`, `subagent`.

### Prueba local (host Linux)

```bash
./tests/probar_http.sh   # build linux + soso, unitarios y E2E contra tests/mock_llm.py
./tests/probar_tui.sh    # sesión interactiva sin args, mock en 7422
python3 tests/mock_llm.py 7422 tests/guiones/read_edit_stop.json   # mock guionizado
out/linux/bin/supercoder run --format json "prompt"
```

En el guest, con `soso-llm serve` (token en `SOSO_LLM_API_KEY`) o un modelo real:

```sh
supercoder run --format json "lee /tmp/oc-fixture.txt"
```

## Modelos

`supercoder run --model MODELO …` (o `-m`) elige el modelo; si no se indica, se usa `"model"` de la configuración y, en su defecto, `soso-coder`. La configuración se lee primero de `.supercoder/supercoder.json` en el directorio de trabajo; si no existe, se usa `supercoder.json` en ese directorio. Si existen ambos, prevalece el archivo de `.supercoder/`. Cada modelo puede hablar con su propio `soso-llm` (puerto en loopback):

```json
{
  "model": "soso-coder",
  "models": {
    "soso-coder": { "host": "127.0.0.1", "port": 7422, "token_env": "SOSO_LLM_API_KEY", "max_tokens": 4096 },
    "otro-modelo": { "port": 7442, "vision": true, "stream": true, "context_chars": 120000 }
  }
}
```

Un modelo sin entrada en `"models"` usa 127.0.0.1:7422. El token Bearer sale de `token`, `token_env`, `token_file` o `$SOSO_LLM_API_KEY`. Sin bloque `"models"` se mantiene el comportamiento anterior (`:7442` en el fichero selecciona 7442).

### Ollama, LM Studio y soso-llm

Los tres hablan `POST /v1/chat/completions` con herramientas, así que no hace falta nada más que apuntar al servidor:

- **soso-llm**: el modelo por defecto (`soso-coder`, 127.0.0.1:7422, token Bearer de `token`/`token_env`/`token_file`/`$SOSO_LLM_API_KEY`).
- **Ollama**: `supercoder run --model ollama:qwen2.5-coder:7b "prompt"`. Sin configuración usa `$OLLAMA_HOST` (`host`, `host:port` o `http://host:port`; `0.0.0.0` se conecta como loopback) o `127.0.0.1:11434`, sin `Authorization` (el token de soso-llm nunca se envía a Ollama). Si no responde, el error recuerda `ollama serve` y `ollama pull`. El modelo debe soportar herramientas (Qwen2.5-Coder, Llama 3.1+, Mistral…).

- **LM Studio**: `supercoder run --model lmstudio:qwen/qwen3-coder "prompt"` (el id del modelo cargado, como lo muestra `lms ls`). Con el servidor local activo (`lms server start`) usa `$LMSTUDIO_HOST` o `127.0.0.1:1234`, sin token; si el servidor exige clave, `"token"`/`"token_env"` en el modelo. En `supercoder.json`: `"provider": "lmstudio"`.

Para fijar el modelo por defecto o las opciones, en `supercoder.json`:

```json
{
  "model": "qwen",
  "models": {
    "qwen":  { "provider": "ollama", "model_id": "qwen2.5-coder:7b", "context_chars": 60000 },
    "vl":    { "provider": "ollama", "model_id": "qwen2.5vl:7b", "vision": true },
    "otro":  { "provider": "ollama", "host": "192.168.1.20", "port": 11434, "model_id": "llama3.1:8b" }
  }
}
```

`"model_id"` es el nombre que se envía al servidor (también sirve para soso-llm); `host`/`port` mandan sobre `$OLLAMA_HOST`.

### Modelos de Anthropic (`claude -p`)

Un modelo puede ejecutarse con la CLI `claude` (Claude Code) en modo no interactivo, sin `soso-llm`:

- `supercoder run --model claude:sonnet "prompt"` (alias o id: `claude:haiku`, `claude:claude-opus-5-5`…), o
- en `supercoder.json`: `"models": { "mi-claude": { "provider": "claude" } }` y `--model mi-claude`.

Se lanza `claude -p --model <modelo> -- <prompt>` (se busca `claude` en el `PATH`) y su respuesta se emite como `text`. En este modo el bucle de herramientas, el prompt de sistema y los permisos los gestiona Claude Code, no supercoder; los tokens salen del `result` de `claude`.

## Extensión de VS Code

`vscode/` contiene una extensión con un panel de chat (barra lateral secundaria, junto al Chat → SuperCoder) que lanza `supercoder run --format json --interactive` en la carpeta del workspace con una sesión por chat y pinta los eventos: herramientas plegables con entrada y salida, lista de tareas, subagentes anidados, botones Permitir/Siempre/Rechazar para los permisos, imágenes pegadas (Ctrl+V) o adjuntas.

```bash
cd vscode && npm install
npm test                  # parser de eventos y runner (usa out/linux/bin/supercoder si existe)
npm run package           # genera supercoder-<ver>.vsix
code --install-extension supercoder-*.vsix
```

También se registra como participante del Chat nativo de VS Code: `@supercoder <mensaje>` y `@supercoder /model <nombre>` (o sin argumento para el selector). Los modelos de supercoder (`supercoder.json`, `claude:*` y `supercoder.models`) aparecen además en el desplegable de modelos del Chat (proveedor «SuperCoder»); `@supercoder` usa el que elijas ahí. Comparte modelo con el panel.

El binario se toma de `supercoder.binaryPath`; si está vacío, de `out/linux/bin/supercoder` del workspace (donde compila `build.sh`) y, si no existe, de `supercoder` en el `PATH`.

Ajustes: `supercoder.binaryPath`, `supercoder.model`, `supercoder.models` (extra del selector; los de `models` en `supercoder.json` se añaden solos), `supercoder.maxTurns`, `supercoder.autoApprove` (`--yes`), `supercoder.historyTurns` (solo `@supercoder`). Comandos: abrir chat, nuevo chat, elegir modelo, enviar selección (también en el menú contextual del editor) adjuntar ficheros y detener. El panel usa la sesión de supercoder (historial real); `@supercoder` reenvía el historial del Chat nativo.

Pruebas HTTP usan servidor mock local; no llaman a modelos reales en CI.

## Release (CI)

La versión canónica está en [`Sal.toml`](Sal.toml) (y en `version_str` de [`src/main.sal`](src/main.sal)).

1. Sube la versión en `Sal.toml` y `src/main.sal`.
2. Crea y empuja el tag que coincida: `git tag v0.5.0 && git push origin v0.5.0`.

El workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) construye y adjunta:

| Artefacto | Contenido |
|-----------|-----------|
| `supercoder-sal-<ver>-linux-x86_64.tar.gz` | `out/linux/bin/supercoder`, `soso-improve-sal`, `VERSION` |
| `supercoder-sal-<ver>-soso-pkg.tar.gz` | Paquete `soso-pkg` (`paquete.txt`, `paquete.pack`, `bin/`, `share/supercoder/VERSION`) |

Empaquetado local: `./scripts/release-build.sh` (requiere repos hermanos `../sal`, `../soso` y `../salkit`).
