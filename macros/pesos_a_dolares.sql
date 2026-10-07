{% macro pesos_a_dolares(columna, tipo_cambio=18.5) %}
    round({{ columna }} / {{ tipo_cambio }}, 2)
{% endmacro %}