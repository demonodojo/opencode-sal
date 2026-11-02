# supercoder-sal

Reimplementación de OpenCode en Sal para soso ([D12](https://github.com/demonodojo/soso/blob/main/docs/self-improvement/DECISIONES.md)).

## Build

```bash
./build.sh
```

Genera:

- `out/bin/*` — ELF **soso** (guest; requiere SDK: `cargo xtask sal-build --cross-only` en repo `soso`).
- `out/linux/bin/*` — binarios **Linux** nativos (`sal build --target linux`); misma fuente, `import "io/…"`, con shim de syscalls en el runtime Sal.

Requiere `sal` en PATH (repo hermano `../sal`).

## Instalación en soso

Desde el monorepo soso:

```bash
cargo xtask pkg-pack supercoder-sal
soso-pkg instalar supercoder-sal
```

## Comandos

- `supercoder` — TUI (logo, sesión y compositor, como OpenCode); `exit`/`quit`/EOF para salir
- `supercoder --version` (0.4.1)
- `supercoder run [--format json] <prompt>` — bucle con herramientas, eventos JSON tipo OpenCode (`step_start`, `tool_use`, `text`, `step_finish`), HTTP a `soso-llm` (`supercoder.json` → puerto 7422/7442)
- `soso-improve-sal campana <dir>` — coordinador (captura, diez pasos, validación)
- `supercoder reinstalar` — reinstala vía `soso-pkg` (borrador)

### Eventos `--format json`

Líneas JSON compatibles con el ejecutor Rust (`runner.rs`): `step_start`, `tool_use`, `text`, `step_finish`, `error`.

### Prueba local (host Linux)

```bash
./tests/probar_http.sh   # build linux + soso, mock en 7422, supercoder run
./tests/probar_tui.sh    # sesión interactiva sin args, mock en 7422
python3 tests/mock_http_server.py 7422   # 1ª respuesta tool read, 2ª content
out/linux/bin/supercoder run --format json "prompt"
printf 'prompt\nexit\n' | out/linux/bin/supercoder
```

En el guest, con `soso-llm serve` y el mock o modelo real:

```sh
supercoder run --format json "lee /tmp/oc-fixture.txt"
```

## Modelos

`supercoder run --model MODELO …` (o `-m`) elige el modelo; si no se indica, se usa `"model"` de `supercoder.json` y, en su defecto, `soso-coder`. Cada modelo puede hablar con su propio `soso-llm` (puerto en loopback):

```json
{
  "model": "soso-coder",
  "models": {
    "soso-coder": { "port": 7422 },
    "otro-modelo": { "port": 7442 }
  }
}
```

Un modelo sin entrada en `"models"` usa 7422. Sin bloque `"models"` se mantiene el comportamiento anterior (`:7442` en el fichero selecciona 7442).

### Modelos de Anthropic (`claude -p`)

Un modelo puede ejecutarse con la CLI `claude` (Claude Code) en modo no interactivo, sin `soso-llm`:

- `supercoder run --model claude:sonnet "prompt"` (alias o id: `claude:haiku`, `claude:claude-opus-5-5`…), o
- en `supercoder.json`: `"models": { "mi-claude": { "provider": "claude" } }` y `--model mi-claude`.

Se lanza `claude -p --model <modelo> -- <prompt>` (se busca `claude` en el `PATH`) y su respuesta se emite como `text`. En este modo el bucle de herramientas, el prompt de sistema y los permisos los gestiona Claude Code, no supercoder; los tokens no se contabilizan (`0`).

## Extensión de VS Code

`vscode/` contiene una extensión con un panel de chat (barra de actividad → SuperCoder) que lanza `supercoder run --format json` en la carpeta del workspace y pinta los eventos (herramientas, texto, tokens).

```bash
cd vscode && npm install
npm test                  # parser de eventos y runner (usa out/linux/bin/supercoder si existe)
npm run package           # genera supercoder-<ver>.vsix
code --install-extension supercoder-*.vsix
```

Ajustes: `supercoder.binaryPath`, `supercoder.model`, `supercoder.models` (extra del selector; los de `models` en `supercoder.json` se añaden solos), `supercoder.maxTurns`, `supercoder.historyTurns`. Comandos: abrir chat, nuevo chat, elegir modelo, enviar selección (también en el menú contextual del editor) y detener. El historial se reenvía como contexto en cada mensaje.

Pruebas HTTP usan servidor mock local; no llaman a modelos reales en CI.

## Release (CI)

La versión canónica está en [`Sal.toml`](Sal.toml) (y en `version_str` de [`src/main.sal`](src/main.sal)).

1. Sube la versión en `Sal.toml` y `src/main.sal`.
2. Crea y empuja el tag que coincida: `git tag v0.4.1 && git push origin v0.4.1`.

El workflow [`.github/workflows/release.yml`](.github/workflows/release.yml) construye y adjunta:

| Artefacto | Contenido |
|-----------|-----------|
| `supercoder-sal-<ver>-linux-x86_64.tar.gz` | `out/linux/bin/supercoder`, `soso-improve-sal`, `VERSION` |
| `supercoder-sal-<ver>-soso-pkg.tar.gz` | Paquete `soso-pkg` (`paquete.txt`, `paquete.pack`, `bin/`, `share/supercoder/VERSION`) |

Empaquetado local: `./scripts/release-build.sh` (requiere repos hermanos `../sal` y `../soso`).
