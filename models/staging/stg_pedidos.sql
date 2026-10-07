select
    id as pedido_id,
    cliente_id,
    fecha_pedido,
    estado,
    monto
from {{ source('raw', 'pedidos') }}