terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_secret_manager_secret" "secret" {
  project   = var.project_id
  secret_id = var.secret_id

  labels = var.labels

  replication {
    auto {} # Single implicit location — stays within Always Free
  }
}

resource "google_secret_manager_secret_version" "secret_version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.secret_data
}
