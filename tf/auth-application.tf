# # # # # # # # # # # # #
# CLOUD RUN APPLICATION #
# # # # # # # # # # # # #
# Creates a Google Cloud Run instance for the Auth-Application
resource "google_cloud_run_service" "auth_application" {

  name = "auth-application"
  location = var.project_region

  template {
    spec {
      containers {
        image = "${var.auth_app_image}:${var.auth_app_tag}"
        # Database
        env {
          name = "AUTH_DB_URL"
          value = google_sql_database_instance.auth-db.connection_name
        }
        env {
          name = "AUTH_DB_NAME"
          value = google_sql_database.auth_db_database.name
        }
        env {
          name = "AUTH_DB_USERNAME"
          value = google_sql_user.auth_db_user.name
        }
        env {
          name = "AUTH_DB_PASSWORD"
          value = google_sql_user.auth_db_user.password
        }
        # Logz.io
        env {
          name = "LOGZIO_TOKEN"
          value = var.logzio_token
        }
        env {
          name = "LOGZIO_URL"
          value = var.logzio_url
        }
        # Spring Profile
        env {
          name = "SPRING_PROFILES_ACTIVE"
          value = "prod"
        }
        resources {
          limits = {
            cpu = "1000m"
            memory = "2048Mi"
          }
        }
      }
    }
    metadata {
      annotations = {
        "run.googleapis.com/client-name"        = "terraform"
        "autoscaling.knative.dev/maxScale"      = "1000"
        "run.googleapis.com/cloudsql-instances" = "${var.project_name}:${var.project_region}:${google_sql_database_instance.auth-db.name}"
      }
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

# # # # # # # # # # # #
# CLOUD SQL DATABASE  #
# # # # # # # # # # # #

# Sets up a PostgreSQL Database Instance on Google Cloud Platform
resource "google_sql_database_instance" "auth-db" {
  name = "postgres-instance-auth-db"
  region = var.project_region
  database_version = "POSTGRES_12"
  settings {
    tier = "db-f1-micro"
  }
}

# Creates a "auth-db" database in the database instance
resource "google_sql_database" "auth_db_database" {
  instance = google_sql_database_instance.auth-db.name
  name = "auth-db"
}

# Creates a "auth-app" user with a randomized password
resource "google_sql_user" "auth_db_user" {
  instance = google_sql_database_instance.auth-db.name
  name = "auth-app"
  password = random_password.auth_db_user_password.result
}

# Generates a random password for the "auth-app" database user
resource "random_password" "auth_db_user_password" {
  length = 32
  special = true
  override_special = "_%@"
}