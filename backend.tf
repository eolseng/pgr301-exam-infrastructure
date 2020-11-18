terraform {
  backend "gcs" {
    credentials = "./keyfiles/gcp_keyfile.json"
    bucket = "pgr301-exam-10004-terraform-state"
  }
}