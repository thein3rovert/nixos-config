terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_storage_bucket" "bucket" {
  project  = var.project_id
  name     = var.bucket_name
  location = var.location

  storage_class = var.storage_class

  # Uniform bucket-level access
  uniform_bucket_level_access = var.uniform_bucket_level_access

  # Versioning
  versioning {
    enabled = var.versioning_enabled
  }

  # Public access prevention
  public_access_prevention = var.public_access_prevention

  # Labels
  labels = var.labels

  # Lifecycle rules
  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                   = lookup(lifecycle_rule.value.condition, "age", null)
        matches_storage_class = lookup(lifecycle_rule.value.condition, "matches_storage_class", null)
        num_newer_versions    = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
      }
    }
  }

  # Force destroy (set to false for production state buckets)
  force_destroy = var.force_destroy
}
