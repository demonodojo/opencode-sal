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

- `supercoder` — TUI (logo, sesión y compositor, como OpenCode); `exit`/`quit`/EOF para salir. Cada turno corre en un proceso `supercoder run` aparte y los permisos se preguntan en línea (`[s]i / [a]siempre / [N]o`).
- `supercoder --version` (0.5.0)
- `supercoder run [opciones] <prompt>` — agente de código con herramientas, historial real, permisos, subagentes e imágenes (ver abajo)
- `supercoder session list` — sesiones guardadas
- `supercoder agents` — agentes disponibles
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
| `--file RUTA` | Adjunta un fichero o una imagen (repetible); también `@ruta` en el prompt |
| `--` | Lo que sigue es el prompt |

El historial completo se guarda en `$SUPERCODER_HOME/sessions/<id>/messages.json` (por defecto `~/.local/share/supercoder`, `/var/supercoder` en soso), junto con las tareas (`todos.json`) y los permisos concedidos con «siempre» (`grants.txt`).

### Herramientas

`read` (líneas numeradas, directorios, imágenes), `write`, `edit` (texto exacto, `replaceAll`), `list`, `glob`, `grep` (regex), `bash` (timeout, salida recortada), `todowrite`/`todoread`, `skill` (carga `SKILL.md` de `.supercoder/skills`, `.opencode/skills` o `.claude/skills`) y `task` (subagentes). Los esquemas JSON se envían al modelo y los argumentos se validan; los errores vuelven al modelo para que corrija.

### Permisos

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

`supercoder run --model MODELO …` (o `-m`) elige el modelo; si no se indica, se usa `"model"` de `supercoder.json` y, en su defecto, `soso-coder`. Cada modelo puede hablar con su propio `soso-llm` (puerto en loopback):

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

### Modelos de Anthropic (`claude -p`)

Un modelo puede ejecutarse con la CLI `claude` (Claude Code) en modo no interactivo, sin `soso-llm`:

- `supercoder run --model claude:sonnet "prompt"` (alias o id: `claude:haiku`, `claude:claude-opus-5-5`…), o
- en `supercoder.json`: `"models": { "mi-claude": { "provider": "claude" } }` y `--model mi-claude`.

Se lanza `claude -p --model <modelo> -- <prompt>` (se busca `claude` en el `PATH`) y su respuesta se emite como `text`. En este modo el bucle de herramientas, el prompt de sistema y los permisos los gestiona Claude Code, no supercoder; los tokens no se contabilizan (`0`).

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
