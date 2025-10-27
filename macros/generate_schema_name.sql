{% macro generate_schema_name(custom_schema_name, node) -%}

    {%- set default_schema = target.schema -%}
    {%- if env_var('DBT_CLOUD_RUN_REASON_CATEGORY','empty') == 'github_pull_request' -%}
        {%- if custom_schema_name is none -%}

            {{ exceptions.raise_compiler_error('Custom schema for model ' ~ node ~ ' not provided!') }}

        {%- else -%}

            dbt_ci_{{ custom_schema_name | trim }}

        {%- endif -%}
    {%- elif env_var('DBT_CLOUD_ENVIRONMENT_TYPE','empty') == 'empty' or env_var('DBT_CLOUD_ENVIRONMENT_TYPE') == 'staging' or env_var('DBT_CLOUD_ENVIRONMENT_TYPE') == 'prod' -%}
        {%- if custom_schema_name is none -%}

            {{ default_schema }}

        {%- else -%}

            {{ custom_schema_name | trim }}

        {%- endif -%}
    
    {%- elif env_var('DBT_CLOUD_ENVIRONMENT_TYPE') == 'dev' -%}

        {{ default_schema }}
 
    {% else %}
        {%- if custom_schema_name is none -%}

            {{ default_schema }}

        {%- else -%}

            {{ custom_schema_name | trim }}

        {%- endif -%}
    {% endif %}
{%- endmacro %}