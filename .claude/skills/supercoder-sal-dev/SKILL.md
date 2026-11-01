---
name: supercoder-sal-dev
description: >-
  Compila, prueba y organiza supercoder-sal, la reimplementación de SuperCoder en
  Sal para soso (D12). Usar al tocar build.sh, Sal.toml, fuentes .sal, tests,
  el empaquetado con soso-pkg, o al preguntar cómo construir supercoder o
  soso-improve-sal para el guest o para Linux.
---

# supercoder-sal — desarrollo

Reimplementación compatible de SuperCoder en Sal. Decisión D12 en el repo hermano `soso` (`docs/self-improvement/DECISIONES.md`). Dos binarios, la misma fuente, dos destinos.

## Layout

| Ruta | Qué es |
|------|--------|
| `src/main.sal` | CLI `supercoder` |
| `src/coord_main.sal` | CLI `soso-improve-sal` |
| `src/*.sal` | Bucle, HTTP, JSON, herramientas, sesión, skills |
| `src/coord/*.sal` | Campaña: captura, ejecutor, validador |
| `out/bin/` | ELF guest (`--target soso`) |
| `out/linux/bin/` | Binarios Linux (`--target linux`) |
| `tests/` | Mock HTTP y humo |

`target/` y `src/target/` son caché del compilador.

El agente (`supercoder run`, herramientas, eventos) está en [supercoder-sal-agente](../supercoder-sal-agente/SKILL.md). La campaña está en [supercoder-sal-campana](../supercoder-sal-campana/SKILL.md).

## Build

Hace falta `sal` en PATH o `../sal/target/release/sal`. El destino guest necesita el SDK del repo `soso`:

```bash
cargo xtask sal-build --cross-only   # en ../soso, una vez
./build.sh                            # en este repo
```

`build.sh` compila `src/main.sal` y `src/coord_main.sal`. El guest usa `SAL_SDK` (`$SOSO_ROOT/target/sal/sdk`) y `rust-lld`. El destino Linux se compila después, sin `SAL_SDK`. Variables: `SOSO_ROOT` (default `../soso`), `SAL_BIN`.

Instalación en el guest, desde el monorepo soso:

```bash
cargo xtask pkg-pack supercoder-sal
soso-pkg instalar supercoder-sal
```

## Pruebas

Las pruebas HTTP hablan con el mock local. No llaman a `soso-llm` ni a un modelo real.

```bash
./tests/probar_http.sh
python3 tests/mock_http_server.py 7422          # read, luego content
python3 tests/mock_http_server.py 7422 edit     # read, edit, content
out/linux/bin/supercoder run --format json --max-turns 1 "prompt"
```

El mock escucha en `127.0.0.1`, atiende una conexión por respuesta y cierra. Puerto por defecto `7422`. `probar_http.sh` construye, arranca el mock, imprime `--version` y las cinco primeras líneas de `run --format json`. `probar_tui.sh` prueba la sesión sin argumentos.

## CI y release

- [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml): en cada PR/push a `main`, checkout de `demonodojo/sal` y `demonodojo/soso`, `scripts/release-build.sh`, `probar_http.sh` y `probar_tui.sh`.
- Publicar versión nueva: skill [supercoder-sal-release](../supercoder-sal-release/SKILL.md) (tag, Release, artefactos).

## Fuentes `.sal`

Sangría de espacios, `fn`, efectos `! io, alloc`, última expresión del bloque como valor. El estilo canónico es el de la skill `sal-fuente` del repo hermano `sal`. Al cerrar un `.sal` tocado: `sal fmt` y, si el binario `standard` está disponible, `standard check` sobre esos ficheros.

Al cambiar el bucle, las herramientas o el formato de eventos, actualizar la skill de ese dominio en el mismo cambio.
