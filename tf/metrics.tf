#* Influx DB Configuration *#
# Creates a database for metrics from the Auth App
resource "influxdb_database" "auth" {
  name = "auth-metrics"
}
# Creates a user for the Auth App that allows it to write to the database
resource "influxdb_user" "auth_app_user" {
  name = "auth_user"
  password = random_password.influx_auth_app.result
  grant {
    # Service User is allowed to write to the database
    database = influxdb_database.auth.name
    privilege = "WRITE"
  }
}
# Creates a user for Grafana to read from the database
resource "influxdb_user" "auth_grafana_user" {
  name = "auth_grafana"
  password = random_password.influx_auth_grafana.result
  grant {
    # Grafana is allowed to read from the database
    database = influxdb_database.auth.name
    privilege = "READ"
  }
}

# Generates a random password for Auth App user
resource "random_password" "influx_auth_app" {
  length = 32
  special = true
  override_special = "_%@"
}

# Generates a random password for Grafana
resource "random_password" "influx_auth_grafana" {
  length = 32
  special = true
  override_special = "_%@"
}

#* Grafana Configuration *#
# Set InfluxDB as a Data Source
resource "grafana_data_source" "auth_metrics" {
  name = "auth-metrics"
  type = "influxdb"
  url = var.influx_url
  username = influxdb_user.auth_grafana_user.name
  password = influxdb_user.auth_grafana_user.password
  database_name = influxdb_database.auth.name
}
# Load a preconfigured dashboard
resource "grafana_dashboard" "beer_metrics" {
  # This will fail in production as the dashboard was created on another data source
  config_json = file("grafana_dashboard.json")
  depends_on = [grafana_data_source.auth_metrics]
}