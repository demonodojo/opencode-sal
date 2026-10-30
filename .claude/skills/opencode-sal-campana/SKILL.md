---
name: opencode-sal-campana
description: >-
  Coordina la automejora en Sal con soso-improve-sal campana: captura de base,
  diez pasos, ejecutor que lanza opencode run y validación que promueve la
  copia. Usar al editar src/coord_main.sal o src/coord/, o al comparar la
  campaña con soso-improve Rust (fichas T90–T93).
---

# Campaña `soso-improve-sal`

Binario distinto de `opencode`: `src/coord_main.sal` → `out/bin/soso-improve-sal` y `out/linux/bin/soso-improve-sal`.

```
soso-improve-sal campana DIR
```

Con menos de 3 argumentos, o con un subcomando distinto de `campana`, escribe el uso en stderr y sale 2.

## Qué hace `campana_diez`

Sobre `DIR`:

1. `captura_base` escribe `DIR/base.txt` con `capturado\n`.
2. Diez veces: escribe `event:paso` en stdout y llama a `ejecutor_run("tarea")`. Cuenta cuántos spawn devuelven 0.
3. `validar_copia` escribe `DIR/verificado` con `ok\n`. `promover_base` escribe `DIR/promovido` con `1\n`. Esas dos escrituras ocurren aunque el recuento sea bajo.
4. Sale 0 si al menos 5 pasos devolvieron 0. Sale 1 en caso contrario.

`ejecutor_run` hace spawn de `/bin/opencode` con argumentos `run`, `--format`, `json` y el prompt (`tarea` en la campaña). stdin/stdout/stderr son 0/1/2. El prompt del paso no sale de un banco de casos: es el literal `tarea`.

En el host Linux el binario de prueba es `out/linux/bin/opencode`. `/bin/opencode` y `/bin/sosh` son rutas del guest.

## Contrato de las fichas

Las fichas T90–T93 viven en `soso/docs/self-improvement/`. El estado de paridad está en `soso/tests/self-improvement/opencode-sal/README.md`:

- T92 compara aceptadas en R41–R50 entre `soso-improve campana` (Rust) y `soso-improve-sal campana DIR` con el mismo modelo servido por soso.
- T93, tras promover, reinstala con `/bin/sal` y `soso-pkg` y hace rollback si la verificación falla.

El código de `src/coord/` captura, cuenta diez spawn y escribe `verificado` y `promovido`. Acercarlo a T92 o T93 es un cambio de comportamiento que hay que pedir aparte.

Las pruebas HTTP de este repo siguen el mock (`tests/mock_http_server.py`). Una campaña contra un modelo real no sustituye a ese mock.
