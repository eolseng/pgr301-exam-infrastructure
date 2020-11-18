resource "google_project_service" "container_registry" {
  project = var.project_name
  service = "containerregistry.googleapis.com"
}