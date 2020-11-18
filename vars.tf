variable "project_name" {
  description = "The name of the GCP project"
  type = string
}

variable "project_region" {
  description = "The region of the GCP project"
  type = string
}

variable "project_keyfile" {
  description = "Path to the keyfile of the GCP Service Account to run Terraform"
  type = string
  default = "./keyfiles/gcp_keyfile.json"
}