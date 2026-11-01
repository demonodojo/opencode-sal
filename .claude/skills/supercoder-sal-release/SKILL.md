---
name: supercoder-sal-release
description: >-
  Publica una nueva versión de supercoder-sal: subir versión en Sal.toml y
  version_str, pruebas, tag vX.Y.Z y GitHub Release con paquetes Linux y soso.
  Usar cuando el usuario pida release, publicar versión, tag, bump de versión o
  artefactos descargables en CI.
---

# supercoder-sal — publicar versión

Versión canónica del **paquete**: [`Sal.toml`](../../../Sal.toml) (`version = "X.Y.Z"`).  
Versión impresa por el binario: [`src/main.sal`](../../../src/main.sal) → `version_str()` debe ser exactamente `supercoder-sal X.Y.Z` (misma `X.Y.Z`).

El workflow [`.github/workflows/release.yml`](../../../.github/workflows/release.yml) exige que el tag **`vX.Y.Z`** coincida con `Sal.toml`. Genera:

| Artefacto | Contenido |
|-----------|-----------|
| `supercoder-sal-<ver>-linux-x86_64.tar.gz` | `out/linux/bin/*`, `VERSION` |
| `supercoder-sal-<ver>-soso-pkg.tar.gz` | `paquete.txt`, `paquete.pack`, `bin/`, `share/supercoder/VERSION` |

Build local de artefactos: [`scripts/release-build.sh`](../../../scripts/release-build.sh) (requiere repos hermanos `../sal` y `../soso`).

## Flujo (seguir en orden)

### 1. Elegir versión

- **Patch** (0.4.0 → 0.4.1): correcciones.
- **Minor** (0.4.0 → 0.5.0): funcionalidad compatible.
- **Major** (0.4.0 → 1.0.0): cambios breaking.

Si el usuario no indica número, proponer el bump adecuado al diff pendiente y confirmar antes de editar.

### 2. Actualizar fuentes

En el mismo commit (cuando el usuario pida commit):

1. `Sal.toml` → `version = "X.Y.Z"`.
2. `src/main.sal` → literal en `version_str()`: `"supercoder-sal X.Y.Z"`.
3. [`README.md`](../../../README.md): línea `supercoder --version` si cita la versión.
4. Skills del agente (`supercoder-sal-agente`): párrafo que menciona `supercoder-sal X.Y.Z` en `version_str`, si existe.

No tocar `SUPERCODER_SAL_VERSION` en el repo `soso` salvo que el usuario pida alinear `cargo xtask pkg-pack supercoder-sal` (el CI de este repo usa [`scripts/pack_soso_pkg.py`](../../../scripts/pack_soso_pkg.py) con la versión de `Sal.toml`).

### 3. Verificar antes del tag

Desde la raíz de **supercoder-sal**:

```bash
chmod +x scripts/*.sh build.sh tests/*.sh
./scripts/release-build.sh
./tests/probar_http.sh
./tests/probar_tui.sh
out/linux/bin/supercoder --version   # debe mostrar supercoder-sal X.Y.Z
./scripts/ci-version.sh            # debe imprimir X.Y.Z
```

Si falta `../sal` o `../soso`, avisar; no inventar artefactos.

### 4. Commit (solo si lo pide el usuario)

Mensaje orientado al release, p. ej. `Release supercoder-sal X.Y.Z`.

### 5. Tag y push

```bash
git tag -a "vX.Y.Z" -m "supercoder-sal X.Y.Z"
git push origin "vX.Y.Z"
```

El push del tag dispara **release** en GitHub Actions y crea la Release con los dos `.tar.gz`.

Alternativa sin tag local: en GitHub → Actions → **release** → **Run workflow** (`workflow_dispatch`); usa la versión actual de `Sal.toml` en la rama seleccionada (debe existir el tag `vX.Y.Z` en remoto o el action creará la release para ese nombre — comprobar en el workflow que `tag_name` sea `v` + `ci-version.sh`).

### 6. Comprobar la Release

```bash
gh release view "vX.Y.Z" --repo demonodojo/supercoder-sal
gh release download "vX.Y.Z" --repo demonodojo/supercoder-sal -D /tmp/oc-release
```

Confirmar que existen los dos archivos y que `tar tzf` lista `bin/supercoder` en ambos paquetes.

## Errores frecuentes

| Síntoma | Causa |
|---------|--------|
| Release falla en «tag no coincide» | Tag `vA.B.C` distinto de `Sal.toml` |
| `release-build.sh` falla | Sin SDK: `cargo xtask sal-build --cross-only` en `../soso` |
| CI: import `fs.sal` no encontrado | El pin viejo de `sal` en soso no basta; CI usa `demonodojo/sal@main` y `sal-source.py --update` antes de `sal-build` |
| `--version` distinto de `Sal.toml` | Olvidado `version_str` en `main.sal` |
| CI verde pero sin Release | Solo se mergeó a `main` sin push del tag `vX.Y.Z` |

## Relacionado

- Desarrollo diario: [supercoder-sal-dev](../supercoder-sal-dev/SKILL.md).
- Agente runtime: [supercoder-sal-agente](../supercoder-sal-agente/SKILL.md).
