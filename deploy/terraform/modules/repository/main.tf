terraform {
  required_providers {
    dbtcloud = {
      source  = "dbt-labs/dbtcloud"
    }
  }
}

resource "dbtcloud_repository" "repository" {
  project_id         = var.project_id
  remote_url         = var.repository_data.remote_url
  gitlab_project_id  = lookup(var.repository_data, "gitlab_project_id", null)
  git_clone_strategy = lookup(var.repository_data, "git_clone_strategy", "deploy_token")
}
