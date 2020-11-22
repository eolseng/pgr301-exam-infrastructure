resource "statuscake_test" "auth_app" {
  website_name  = google_cloud_run_service.auth_application.name
  website_url   = google_cloud_run_service.auth_application.status[0].url
  test_type     = "HTTP"
  check_rate    = 300
  contact_group = [var.statuscake_contact_group]
}