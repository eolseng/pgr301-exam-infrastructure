terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 3.48.0"
    }
  }
}

provider "google" {
  project = var.project_name
  region = var.project_region
  credentials = file(var.project_keyfile)
}
