# Tienda: proyecto de práctica con dbt y DuckDB

Proyecto de dbt Core que transforma datos de clientes y pedidos de una tienda ficticia. Corre completamente en local con DuckDB, sin necesidad de un warehouse en la nube.

## Qué cubre

| Concepto | Dónde verlo |
| --- | --- |
| Seeds | `seeds/clientes.csv`, `seeds/pedidos.csv` (cargados al esquema `main_raw`) |
| Sources | `models/staging/_sources.yml` |
| Capa staging (vistas) | `models/staging/stg_clientes.sql`, `stg_pedidos.sql` |
| Capa marts (tablas) | `models/marts/dim_clientes.sql` |
| Modelo incremental | `models/marts/fct_pedidos.sql` (`is_incremental()`, `unique_key`) |
| Snapshot (SCD tipo 2) | `snapshots/clientes_snapshot.yml` (estrategia `check`) |
| Macro con Jinja | `macros/pesos_a_dolares.sql` |
| Tests genéricos | `unique`, `not_null`, `relationships`, `accepted_values` en `_staging.yml` |
| Test singular | `tests/pedidos_monto_positivo.sql` |
| Paquetes | `dbt_utils` (`accepted_range`) en `packages.yml` |
| Documentación y linaje | `dbt docs generate` y `dbt docs serve` |

## Linaje

```
raw.clientes ──> stg_clientes ──┐
                                ├──> dim_clientes
raw.pedidos  ──> stg_pedidos  ──┤
                                └──> fct_pedidos (incremental)

raw.clientes ──> clientes_snapshot
```

## Cómo ejecutarlo

Requiere Python 3.10 o superior.

```bash
python -m venv venv
venv\Scripts\activate          # Windows
source venv/bin/activate       # Mac / Linux

pip install dbt-core dbt-duckdb
```

Agrega este perfil a `~/.dbt/profiles.yml`:

```yaml
tienda:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: dev.duckdb
      threads: 1
```

Luego, desde la carpeta del proyecto:

```bash
dbt deps      # instala dbt_utils
dbt build     # seeds, modelos, snapshot y tests en orden del DAG
```

## Decisiones de diseño

- **Staging como vistas, marts como tablas.** Staging solo renombra y limpia, así que una vista basta y siempre refleja el dato crudo. Los marts se consultan con frecuencia y conviene tenerlos calculados.
- **`source()` solo en staging.** El resto de los modelos usa `ref()`, de modo que un cambio en los datos crudos se absorbe en un solo lugar.
- **Seeds como datos crudos.** En un proyecto real los datos crudos los carga una herramienta de ingesta. Aquí los seeds se envían a un esquema `raw` separado para simular ese escenario y poder declarar sources.
- **`dbt build` en lugar de `run` + `test`.** Si un test falla en staging, los modelos que dependen de él no se construyen y el dato malo no llega a los marts.

## Limitaciones conocidas

- `fct_pedidos` filtra por `fecha_pedido`, por lo que no detecta cambios en pedidos ya cargados (por ejemplo, un cambio de estado). En producción se filtraría por una columna `updated_at`, posiblemente con una ventana hacia atrás para datos que llegan tarde. Mientras tanto, se corrige con `dbt run --select fct_pedidos --full-refresh`.
- El snapshot usa la estrategia `check` porque los datos no tienen `updated_at`. Con esa columna, la estrategia `timestamp` sería preferible.
- El tipo de cambio de la macro `pesos_a_dolares` es un valor fijo por defecto, no una tasa real.