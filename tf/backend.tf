terraform {
  backend "gcs" {
    credentials = "gcp_keyfile.json"
    bucket = "pgr301-exam-10004-terraform-state"
  }
}