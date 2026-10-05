variable "project_id" {
  type = string
}

variable "environment" {
  type = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod"
  }
}

variable "region" {
  type    = string
  default = "us-central1-a"
}

variable "bigtable_num_nodes" {
  type    = number
  default = 3
}
