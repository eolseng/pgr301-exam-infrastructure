resource "google_project_service" "container_registry" {
  project = var.project_name
  service = "containerregistry.googleapis.com"
}

resource "google_project_service" "cloud_run" {
  project = var.project_name
  service = "run.googleapis.com"
}

resource "google_project_service" "sqladmin" {
  project = var.project_name
  service = "sqladmin.googleapis.com"
}