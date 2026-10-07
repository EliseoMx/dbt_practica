select
    id as cliente_id,
    nombre,
    ciudad,
    fecha_registro
from {{ source('raw', 'clientes') }}