# opencode-sal

Reimplementación de OpenCode en Sal para soso ([D12](https://github.com/demonodojo/soso/blob/main/docs/self-improvement/DECISIONES.md)).

## Build (host → ELF soso)

```bash
./build.sh
```

Requiere `sal` en PATH (repo hermano `../sal`) y SDK de soso (`cargo xtask sal-build --cross-only` en repo `soso`).

## Instalación en soso

Desde el monorepo soso:

```bash
cargo xtask pkg-pack opencode-sal
soso-pkg instalar opencode-sal
```

## Comandos

- `opencode --version`
- `opencode run [--format json] <prompt>`
- `opencode campana <dir>` — coordinador (diez tareas, validación en copia)
- `opencode reinstalar` — autorecompila e reinstala el paquete (T93)

Pruebas HTTP usan servidor mock local; no llaman a modelos reales en CI.
