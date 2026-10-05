terraform {
  source = "./"
}

remote_state {
  backend = "gcs"
  config = {
    bucket = "telecom-dev-terraform-state"
    prefix = "bootstrap"
  }
}
