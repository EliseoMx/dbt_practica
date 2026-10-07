with clientes as (
    select * from {{ ref('stg_clientes') }}
),

pedidos as (
    select * from {{ ref('stg_pedidos') }}
),

resumen as (
    select
        cliente_id,
        count(*) as total_pedidos,
        sum(monto) as monto_total,
        max(fecha_pedido) as ultimo_pedido
    from pedidos
    where estado = 'completado'
    group by cliente_id
)

select
    c.cliente_id,
    c.nombre,
    c.ciudad,
    c.fecha_registro,
    coalesce(r.total_pedidos, 0) as total_pedidos,
    coalesce(r.monto_total, 0) as monto_total,
    r.ultimo_pedido
from clientes c
left join resumen r on c.cliente_id = r.cliente_id