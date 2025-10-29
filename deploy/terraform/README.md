# dbt-cloud-projects
This repository contains Terraform modules for managing dbt Cloud projects and their resources. The structure is designed for flexibility and scalability, allowing users to define configurations using YAML files.

## YAML Spec
Below is the full YAML specification that defines the keys you can configure and the data type each value is expected to be:

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trouze/dbt-cloud-terraform-starter/refs/heads/main/schemas/project/v1.json
project:
  name: <string> # Required. Name of the dbt project.
  repository:
    remote_url: <string> # Required. URL of the remote Git repository.
    gitlab_project_id: <number> # Optional. GitLab project ID if using GitLab integration.
  environments:
    - name: <string> # Required. Name of the environment.
      credential:
        token_name: <string> # Optional. Name of the token to use.
        schema: <string> # Optional. Schema to be used.
        catalog: <string> # Optional. Catalog to be used.
      connection_id: <number> # Required. Connection ID for the environment.
      type: <string> # Required. Type of environment. Allowed values: 'development', 'deployment'.
      dbt_version: <string> # Optional. dbt version to use. Defaults to "latest".
      enable_model_query_history: <boolean> # Optional. Enable model query history. Defaults to false.
      custom_branch: <string> # Optional. Custom branch for dbt. Defaults to null.
      deployment_type: <string> # Optional. Deployment type (e.g., 'production'). Defaults to null.
      jobs:
        - name: <string> # Required. Name of the job.
          execute_steps: 
            - <string> # Required. Steps to execute in the job.
          triggers:
            github_webhook: <boolean> # Required. Trigger job on GitHub webhook.
            git_provider_webhook: <boolean> # Required. Trigger job on Git provider webhook.
            schedule: <boolean> # Required. Trigger job on a schedule.
            on_merge: <boolean> # Required. Trigger job on merge.
          dbt_version: <string> # Optional. dbt version for the job. Defaults to "latest".
          deferring_environment: <string> # Optional. Enable deferral of job to environment. Defaults to no deferral.
          description: <string> # Optional. Description of the job. Defaults to null.
          errors_on_lint_failure: <boolean> # Optional. Fail job on lint errors. Defaults to true.
          generate_docs: <boolean> # Optional. Generate docs. Defaults to false.
          is_active: <boolean> # Optional. Whether the job is active. Defaults to true.
          num_threads: <number> # Optional. Number of threads for the job. Defaults to 4.
          run_compare_changes: <boolean> # Optional. Compare changes before running. Defaults to false.
          run_generate_sources: <boolean> # Optional. Generate sources before running. Defaults to false.
          run_lint: <boolean> # Optional. Run lint before running. Defaults to false.
          schedule_cron: <string> # Optional. Cron schedule for the job. Defaults to null.
          schedule_days: <array> of <ints> # Optional. Days for schedule. Defaults to null. e.g. [0, 1, 2]
          schedule_hours: <array> of <ints> # Optional. Hours for schedule. Defaults to null. e.g. [0, 1, 2]
          schedule_interval: <string> # Optional. Interval for schedule. Defaults to null.
          schedule_type: <string> # Optional. Type of schedule. Defaults to null.
          self_deferring: <boolean> # Optional. Whether the job is self-deferring. Defaults to false.
          target_name: <string> # Optional. Target name for the job. Defaults to null.
          timeout_seconds: <number> # Optional. Job timeout in seconds. Defaults to 0.
          triggers_on_draft_pr: <boolean> # Optional. Trigger job on draft PRs. Defaults to false.
          env_var_overrides:
            <ENV_VAR>: <string> # Optional. Specify a job env var override
  environment_variables:
    - name: DBT_<string> # Required. Name of the environment variable. Starts with DBT_
      environment_values:
        - env: project
          value: <string> # Optional. Environment value
        - env: Production
          value: <string> # Optional. Environment value
        - env: UAT
          value: <string> # Optional. Environment value
        - env: Development
          value: <string> # Optional. Environment value
    - name: DBT_SECRET_<string> # Required. Name of the secret environment variable. Starts with DBT_SECRET_
      environment_values:
        - env: project
          value: secret_<string> # Optional. Environment value
        - env: Production
          value: secret_<string> # Optional. Environment value
        - env: UAT
          value: secret_<string> # Optional. Environment value
        - env: Development
          value: secret_<string> # Optional. Environment value
```

## Getting Secrets to deploy via Terraform
In order to deploy secrets you'll need to:
1. Add variable to Gitlab variables
2. Add the variable to the Terraform-ci.gitlab-ci.yml environment variables `TF_VAR_my_secret: $gitlab_variable_secret_name`
3. In credentials, make a reference to the variable using everything that comes after `TF_VAR_` -> 
```
credential:
  token_name: my_secret
```

4. In environment variables that you'd like to be secret, use the prefix `secret_` to reference the variable (loaded into the environment variables) and add everything that comes after `TF_VAR_` ->
```
  environment_variables:
    - name: DBT_SECRET_<string> # Required. Name of the secret environment variable. Starts with DBT_SECRET_
      environment_values:
        - env: project
          value: secret_<string> # Optional. Environment value
        - env: Production
          value: secret_<string> # Optional. Environment value
        - env: UAT
          value: secret_<string> # Optional. Environment value
        - env: Development
          value: secret_<string> # Optional. Environment value
```

## Importing existing Terraform resources into state & the YAML Spec
`dbtcloud-terraforming` supports a `generate` command that generates all resource blocks associated with a project. You can use this and copy into a `.tf` file that you can then run `terraform plan` & `terraform apply` which will bulk import these resources into the terraform state so they're under management.

```
dbtcloud-terraforming generate --resource-types <types> -p <project_int> --modern-import-block
```

While this package does support the ability to create import blocks and use `terraform apply` to bulk import existing resources to be under terraform state management, because we are storing configurations in YAML and loading it to terraform it is much more difficult to reverse engineer this. I suggest using the above command to pull down existing configurations and manually convert them to the YAML spec. This is a one time process, and once under terraform management you should not be continuously trying to import existing state.

## Development Flow
To develop on this repository, `cd` into the `dbtcloud-kv271-70403103916054` folder and run `terraform init`. Ensure you have a `.tfvars` file or environment variables set that define:

```
dbt_account_id = 1234
dbt_token = "dbtc_z123"
dbt_host_url = "https://kv271.us1.dbt.com/api"
# optionally
databricks_tokens='{"token_some_name": "secure-token-123"}'
```

## Loading credentials into the env
Please use the following pattern to load dbx tokens into the environment so terraform can set them in dbt Cloud.
```
export TF_VAR_databricks_tokens='{
  "token_some_name": "secure-token-123",
  "token_other_name": "secure-token-456"
}'
```

## Using this module
This module is meant to be used for one project at a time, so as to not inadvertently impact multiple projects at once. We do this through specifying the `yaml_file` path for Terraform to load the configuration from.

```
terraform plan/apply \
-var "yaml_file=./deploy/terraform/dbtcloud-kv271-70403103916054/projects/demo_project/demo_project.yml" \
-var-file=".tfvars" \
-state="./deploy/terraform/dbtcloud-kv271-70403103916054/projects/demo_project/demo_project.tfstate" \
```

## Credential Rotation
You can use the same terraform module to *only* apply Databricks credentials:
```
terraform apply \
-var "yaml_file=./deploy/terraform/dbtcloud-kv271-70403103916054/projects/demo_project/demo_project.yml" \
-var-file=".tfvars" \
-state="./deploy/terraform/dbtcloud-kv271-70403103916054/projects/demo_project/demo_project.tfstate" \
-target=module.credentials
```
