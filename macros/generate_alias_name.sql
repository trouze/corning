{% macro generate_alias_name(custom_alias_name=none, node=none) -%}
    {%- if env_var('DBT_CLOUD_RUN_REASON_CATEGORY','empty') == 'github_pull_request' -%}
        {% set alias_suffix = env_var('DBT_CLOUD_JOB_ID') ~ '_' ~ env_var('DBT_CLOUD_PR_ID') %}

        {%- if custom_alias_name -%}

            {{ custom_alias_name | trim }}_{{ alias_suffix }}

        {%- elif node.version -%}

            {{ return(node.name ~ "_v" ~ (node.version | replace(".", "_"))) }}_{{ alias_suffix }}

        {%- else -%}

            {{ node.name }}_{{ alias_suffix }}

        {%- endif -%}
    {%- else -%}
        {%- if custom_alias_name -%}

            {{ custom_alias_name | trim }}

        {%- elif node.version -%}

            {{ return(node.name ~ "_v" ~ (node.version | replace(".", "_"))) }}

        {%- else -%}

            {{ node.name }}

        {%- endif -%}
    {%- endif -%}

{%- endmacro %}