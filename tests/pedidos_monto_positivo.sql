select *
from {{ ref('stg_pedidos') }}
where monto <= 0