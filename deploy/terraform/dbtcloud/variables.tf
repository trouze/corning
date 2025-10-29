// define the variables we will use
variable "dbt_account_id" {
  type = number
}

variable "dbt_token" {
  type = string
  sensitive = true
}

variable "dbt_pat" {
  type = string
  sensitive = true
  default = ""
}

variable "dbt_host_url" {
  type = string
}

# variables
variable "yaml_file" {
  description = "Path to the JSON file"
  type        = string
}

variable "target_name" {
  description = "Target CI or Production"
  default = ""
  type = string
}

# load json project configuration file
locals {
  project_config = yamldecode(file(var.yaml_file))
}

# there could be multiple credentials
variable "token_map" {
  type        = map(string)
  default     = null
  description = "Dictionary of credentials to pass to terraform module"
  sensitive   = true
}
