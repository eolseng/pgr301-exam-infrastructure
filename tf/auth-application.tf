resource "google_cloud_run_service" "auth_application" {

  name = "auth-application"
  location = var.project_region

  metadata {
    annotations = {
      "run.googleapis.com/client-name" = "terraform"
    }
  }

  template {
    spec {
      containers {
        image = "eu.gcr.io/${var.project_name}/pgr301-exam-auth:latest"
      }
    }
  }

  traffic {
    latest_revision = true
    percent = 100
  }

  autogenerate_revision_name = true

}