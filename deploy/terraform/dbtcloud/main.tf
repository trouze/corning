terraform {
    required_providers {
        dbtcloud = {
            source = "dbt-labs/dbtcloud"
            version = "~> 0.3"
        }
    }
}

provider "dbtcloud" {
  account_id = var.dbt_account_id
  token      = var.dbt_token
  host_url   = var.dbt_host_url
}

provider "dbtcloud" {
  alias = "pat_provider"
  host_url = var.dbt_host_url
  account_id = var.dbt_account_id
  token = var.dbt_token
}

module "project" {
    source = "../modules/project"

    // inputs
    project_name = local.project_config.project.name
    target_name = var.target_name
    // outputs module.project.project_id
}

module "repository" {
  source          = "../modules/repository"
  providers = {
    dbtcloud = dbtcloud.pat_provider
  }
  // inputs
  repository_data = local.project_config.project.repository
  project_id      = module.project.project_id
  // outputs module.repository.repository_id
}

module "project_repository" {
  source = "../modules/project_repository"
  // inputs
  repository_id = module.repository.project_repository_id
  project_id = module.project.project_id
  // outputs module.project_repository.project_repository_id
}

module "credentials" {
  source = "../modules/credentials"
  // inputs
  environments_data = local.project_config.project.environments
  project_id = module.project.project_id
  token_map = var.token_map
  // outputs module.credentials.credential_id
}

module "environments" {
  source = "../modules/environments"
  // inputs
  project_id       = module.project.project_id  # Assuming project_id is output from the project module
  environments_data = local.project_config.project.environments # Data loaded from the json config
  credential_ids   = module.credentials.credential_ids  # Output from the credentials module
  // outputs module.environments.environment_ids
}

module "jobs" {
  source = "../modules/jobs"
  // inputs
  project_id = module.project.project_id
  environments_data = local.project_config.project.environments
  environment_ids = module.environments.environment_ids
  // outputs module.jobs.job_ids
}

module "environment_variables" {
  source = "../modules/environment_variables"
  // inputs
  project_id = module.project.project_id
  environment_variables = lookup(local.project_config.project, "environment_variables", {})
  environment_ids = module.environments.environment_ids
  token_map = var.token_map

  depends_on = [module.environments]
}

module "environment_variable_job_overrides" {
  source = "../modules/environment_variable_job_overrides"
  // inputs
  project_id = module.project.project_id
  environments_data = local.project_config.project.environments
  job_ids = module.jobs.job_ids

  
  depends_on = [module.environment_variables]
}
