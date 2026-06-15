{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- if custom_schema_name is not none -%}

        {# If a custom schema like 'gold' is defined, use it directly #}
        {{ custom_schema_name | trim }}

    {%- else -%}

        {# Fall back to your profile default (silver) if no custom schema is provided #}
        {{ target.schema }}

    {%- endif -%}

{%- endmacro %}