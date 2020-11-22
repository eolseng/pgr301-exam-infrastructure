terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 3.48.0"
    }
    statuscake = {
      source = "terraform-providers/statuscake"
      version = "~> 1.0.0"
    }
    influxdb = {
      source = "terraform-providers/influxdb"
      version = "~> 1.3.1"
    }
    grafana = {
      source = "terraform-providers/grafana"
      version = "~> 1.7.0"
    }
    random = {
      source = "hashicorp/random"
      version = "~> 3.0.0"
    }
  }
}

provider "google" {
  project = var.project_name
  region = var.project_region
  credentials = file(var.project_keyfile)
}

provider "statuscake" {
  username = var.statuscake_username
  apikey = var.statuscake_apikey
}

provider "influxdb" {
  url = var.influx_url
  username = var.influx_username
  password = var.influx_password
}

provider "grafana" {
  url = var.grafana_url
  auth = var.grafana_auth
}