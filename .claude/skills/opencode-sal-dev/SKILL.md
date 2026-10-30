---
name: opencode-sal-dev
description: >-
  Compila, prueba y organiza opencode-sal, la reimplementación de OpenCode en
  Sal para soso (D12). Usar al tocar build.sh, Sal.toml, fuentes .sal, tests,
  el empaquetado con soso-pkg, o al preguntar cómo construir opencode o
  soso-improve-sal para el guest o para Linux.
---

# opencode-sal — desarrollo

Reimplementación compatible de OpenCode en Sal. Decisión D12 en el repo hermano `soso` (`docs/self-improvement/DECISIONES.md`). Dos binarios, la misma fuente, dos destinos.

## Layout

| Ruta | Qué es |
|------|--------|
| `src/main.sal` | CLI `opencode` |
| `src/coord_main.sal` | CLI `soso-improve-sal` |
| `src/*.sal` | Bucle, HTTP, JSON, herramientas, sesión, skills |
| `src/coord/*.sal` | Campaña: captura, ejecutor, validador |
| `Sal.toml` | Dependencia `soso` en `../sal/std/soso` |
| `out/bin/` | ELF guest (`--target soso`) |
| `out/linux/bin/` | Binarios Linux (`--target linux`) |
| `tests/` | Mock HTTP y humo |

`target/` y `src/target/` son caché del compilador.

El agente (`opencode run`, herramientas, eventos) está en [opencode-sal-agente](../opencode-sal-agente/SKILL.md). La campaña está en [opencode-sal-campana](../opencode-sal-campana/SKILL.md).

## Build

Hace falta `sal` en PATH o `../sal/target/release/sal`. El destino guest necesita el SDK del repo `soso`:

```bash
cargo xtask sal-build --cross-only   # en ../soso, una vez
./build.sh                            # en este repo
```

`build.sh` compila `src/main.sal` y `src/coord_main.sal`. El guest usa `SAL_SDK` (`$SOSO_ROOT/target/sal/sdk`) y `rust-lld`. El destino Linux se compila después, sin `SAL_SDK`. Variables: `SOSO_ROOT` (default `../soso`), `SAL_BIN`.

Instalación en el guest, desde el monorepo soso:

```bash
cargo xtask pkg-pack opencode-sal
soso-pkg instalar opencode-sal
```

## Pruebas

Las pruebas HTTP hablan con el mock local. No llaman a `soso-llm` ni a un modelo real.

```bash
./tests/probar_http.sh
python3 tests/mock_http_server.py 7422          # read, luego content
python3 tests/mock_http_server.py 7422 edit     # read, edit, content
out/linux/bin/opencode run --format json --max-turns 1 "prompt"
```

El mock escucha en `127.0.0.1`, atiende una conexión por respuesta y cierra. Puerto por defecto `7422`. `probar_http.sh` construye, arranca el mock, imprime `--version` y las cinco primeras líneas de `run --format json`.

## Fuentes `.sal`

Sangría de espacios, `fn`, efectos `! io, alloc`, última expresión del bloque como valor. El estilo canónico es el de la skill `sal-fuente` del repo hermano `sal`. Al cerrar un `.sal` tocado: `sal fmt` y, si el binario `standard` está disponible, `standard check` sobre esos ficheros.

Al cambiar el bucle, las herramientas o el formato de eventos, actualizar la skill de ese dominio en el mismo cambio.
