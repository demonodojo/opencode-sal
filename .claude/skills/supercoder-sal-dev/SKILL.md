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
| `src/agent/`, `src/provider/`, `src/tools/`, `src/*.sal` | Bucle, proveedores, herramientas, permisos, agentes, sesión, skills |
| `src/coord/*.sal` | Campaña: captura, ejecutor, validador |
| `out/bin/` | ELF guest (`--target soso`) |
| `out/linux/bin/` | Binarios Linux (`--target linux`) |
| `sal_modules/` | Enlaces creados por `sal install` (`io`, `salkit`); no se versiona |
| `tests/` | Unitarios `tests/sal`, mock `mock_llm.py`, guiones y E2E |

`target/` y `src/target/` son caché del compilador.

El agente (`supercoder run`, herramientas, eventos) está en [supercoder-sal-agente](../supercoder-sal-agente/SKILL.md). La campaña está en [supercoder-sal-campana](../supercoder-sal-campana/SKILL.md).

## Build

Hace falta el repo hermano `../salkit` (dependencia `path` de `Sal.toml`; JSON, regex, glob, HTTP, procesos) y `sal` en PATH o `../sal/target/release/sal`. El destino guest necesita el SDK del repo `soso`:

```bash
cargo xtask sal-build --cross-only   # en ../soso, una vez
./build.sh                            # en este repo
```

`build.sh` ejecuta `sal install` (enlaza `sal_modules/io` y `sal_modules/salkit`) y compila `src/main.sal` y `src/coord_main.sal`. El guest usa `SAL_SDK` (`$SOSO_ROOT/target/sal/sdk`) y `rust-lld`. El destino Linux se compila después, sin `SAL_SDK`. Variables: `SOSO_ROOT` (default `../soso`), `SAL_BIN`.

Instalación en el guest, desde el monorepo soso:

```bash
cargo xtask pkg-pack supercoder-sal
soso-pkg instalar supercoder-sal
```

## Pruebas

Las pruebas hablan con el mock local (`tests/mock_llm.py`); no llaman a `soso-llm` ni a un modelo real.

```bash
tests/probar_sal.sh                 # unitarios tests/sal/test_*.sal
OC_SAL_E2E=1 tests/probar_sal.sh    # + E2E con el binario linux (hay que ejecutar ./build.sh antes)
./tests/probar_http.sh              # build + unitarios + E2E
./tests/probar_tui.sh               # TUI con permiso interactivo
python3 tests/mock_llm.py 7422 tests/guiones/read_edit_stop.json
cd vscode && npm test               # extensión
```

Los E2E usan `SUPERCODER_HOME` y `SOSO_LLM_API_KEY=test-key`. El mock sirve SSE o JSON según `stream` de la petición; pasos: `tool_calls` (con `fragments` para trocear argumentos), `content` (con `deltas`), `error` con `status`. Los unitarios escriben bajo `target/*test` (el script los limpia). Los de salkit: `cd ../salkit && sal install && sal test`.

## CI y release

- [`.github/workflows/ci.yml`](../../.github/workflows/ci.yml): en cada PR/push a `main`, checkout de `demonodojo/sal`, `demonodojo/salkit` y `demonodojo/soso`, `scripts/release-build.sh`, `probar_http.sh` y `probar_tui.sh`.
- Publicar versión nueva: skill [supercoder-sal-release](../supercoder-sal-release/SKILL.md) (tag, Release, artefactos).

## Fuentes `.sal`

Sangría de espacios, `fn`, efectos `! io, alloc`, última expresión del bloque como valor. El estilo canónico es el de la skill `sal-fuente` del repo hermano `sal`. Al cerrar un `.sal` tocado: `sal fmt` y, si el binario `standard` está disponible, `standard check` sobre esos ficheros.

Al cambiar el bucle, las herramientas o el formato de eventos, actualizar la skill de ese dominio en el mismo cambio.
