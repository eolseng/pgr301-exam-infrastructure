resource "google_container_registry" "registry" {
  project = var.project_name
  location = var.container_registry_location
}
