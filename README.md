# opencode-sal

Reimplementación de OpenCode en Sal para soso ([D12](https://github.com/demonodojo/soso/blob/main/docs/self-improvement/DECISIONES.md)).

## Build

```bash
./build.sh
```

Genera:

- `out/bin/*` — ELF **soso** (guest; requiere SDK: `cargo xtask sal-build --cross-only` en repo `soso`).
- `out/linux/bin/*` — binarios **Linux** nativos (`sal build --target linux`); misma fuente y `std/soso`, con shim de syscalls en el runtime Sal.

Requiere `sal` en PATH (repo hermano `../sal`).

## Instalación en soso

Desde el monorepo soso:

```bash
cargo xtask pkg-pack opencode-sal
soso-pkg instalar opencode-sal
```

## Comandos

- `opencode` — sesión interactiva por líneas (comando por defecto del OpenCode original); `exit`/`quit`/EOF para salir
- `opencode --version` (0.4.0)
- `opencode run [--format json] <prompt>` — bucle con herramientas, eventos JSON tipo OpenCode (`step_start`, `tool_use`, `text`, `step_finish`), HTTP a `soso-llm` (`opencode.json` → puerto 7422/7442)
- `soso-improve-sal campana <dir>` — coordinador (captura, diez pasos, validación)
- `opencode reinstalar` — reinstala vía `soso-pkg` (borrador)

### Eventos `--format json`

Líneas JSON compatibles con el ejecutor Rust (`runner.rs`): `step_start`, `tool_use`, `text`, `step_finish`, `error`.

### Prueba local (host Linux)

```bash
./tests/probar_http.sh   # build linux + soso, mock en 7422, opencode run
./tests/probar_tui.sh    # sesión interactiva sin args, mock en 7422
python3 tests/mock_http_server.py 7422   # 1ª respuesta tool read, 2ª content
out/linux/bin/opencode run --format json "prompt"
printf 'prompt\nexit\n' | out/linux/bin/opencode
```

En el guest, con `soso-llm serve` y el mock o modelo real:

```sh
opencode run --format json "lee /tmp/oc-fixture.txt"
```

Pruebas HTTP usan servidor mock local; no llaman a modelos reales en CI.
