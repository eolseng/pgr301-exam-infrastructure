resource "google_cloud_run_service" "auth_application" {

  name = "auth-application"
  location = var.project_region

  template {
    spec {
      containers {
        image = "eu.gcr.io/${var.project_name}/pgr301-exam-auth:897180d59c8e2b28800ac94fd72b9e7a2339e553"
        env {
          name = "LOGZIO_TOKEN"
          value = var.logzio_token
        }
        env {
          name = "LOGZIO_URL"
          value = var.logzio_url
        }
        env {
          # Set the Spring Profile to 'prod' to enable LOGZ.IO and disable InfluxDB exporting
          name = "SPRING_PROFILES_ACTIVE"
          value = "prod"
        }
        resources {
          limits = {
            cpu = "1000m"
            memory = "1024Mi"
          }
        }
      }
    }
  }
  metadata {
    annotations = {
      "run.googleapis.com/client-name" = "terraform"
      "run.googleapis.com/cloudsql-instances" = "${var.project_name}:${var.project_region}:${google_sql_database_instance.auth-db.name}"
    }
  }
  traffic {
    latest_revision = true
    percent = 100
  }
  autogenerate_revision_name = true
}

data "google_iam_policy" "cloud_run_noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers"
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "auth_application_noauth" {
  location = google_cloud_run_service.auth_application.location
  project = google_cloud_run_service.auth_application.project
  service = google_cloud_run_service.auth_application.name

  policy_data = data.google_iam_policy.cloud_run_noauth.policy_data
}

resource "google_sql_database_instance" "auth-db" {
  name = "postgres-instance-auth-db"
  region = var.project_region
  database_version = "POSTGRES_12"
  settings {
    tier = "db-f1-micro"
  }
}