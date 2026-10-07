{{ config(
    materialized='incremental',
    unique_key='pedido_id'
) }}

select
    pedido_id,
    cliente_id,
    fecha_pedido,
    estado,
    monto,
    {{ pesos_a_dolares('monto') }} as monto_usd
from {{ ref('stg_pedidos') }}

{% if is_incremental() %}
where fecha_pedido > (select max(fecha_pedido) from {{ this }})
{% endif %}