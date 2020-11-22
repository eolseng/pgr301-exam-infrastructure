variable "project_name" {
  description = "The name of the GCP project."
  type = string
}

variable "project_region" {
  description = "The region of the GCP project."
  type = string
}

variable "project_keyfile" {
  description = "Path to the keyfile of the GCP Service Account to run Terraform."
  type = string
  default = "gcp_keyfile.json"
}

variable "container_registry_location" {
  description = "The location of the Container Registry."
  type = string
  default = "EU"

  validation {
    condition = contains(["EU", "US", "ASIA"], var.container_registry_location)
    error_message = "Container Registry Location must be one of the following: ['EU', 'US', 'ASIA']."
  }
}

variable "auth_app_image" {
  description = "URI for the Auth App image"
  type = string
}

variable "auth_app_tag" {
  description = "Tag for the Auth App"
  type = string
}

variable "logzio_token" {
  description = "User Token for Logz.io"
  type = string
}

variable "logzio_url" {
  description = "Listener URL for Logz.io"
  type = string
}

variable "statuscake_username"{
  description = "Username of the StatusCake account"
  type = string
}

variable "statuscake_apikey" {
  description = "API Key for the StatusCake account"
  type = string
}

variable "statuscake_contact_group" {
  description = "ID of the contact group to be contacted if service goes down"
  type = string
}
