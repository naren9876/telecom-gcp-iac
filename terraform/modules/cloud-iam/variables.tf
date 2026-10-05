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

variable "service_account_roles" {
  type = list(string)
  default = [
    "roles/spanner.client",
    "roles/bigtable.user",
    "roles/bigquery.dataEditor",
    "roles/pubsub.editor",
    "roles/datastore.user",
    "roles/cloudkms.cryptoKeyEncrypterDecrypter",
  ]
}
