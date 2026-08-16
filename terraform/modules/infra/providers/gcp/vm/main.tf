terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

resource "google_compute_instance" "vm" {
  project      = var.project_id
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = concat(["terraform"], var.tags)

  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = var.boot_disk_type
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    # Conditional access config for external IP
    dynamic "access_config" {
      for_each = var.enable_external_ip ? [1] : []
      content {
        nat_ip = var.static_external_ip
        # If static_external_ip is null, an ephemeral IP is assigned
      }
    }
  }

  metadata = merge(
    {
      ssh-keys = var.ssh_keys
    },
    var.metadata
  )

  metadata_startup_script = var.startup_script

  labels = var.labels

  allow_stopping_for_update = var.allow_stopping_for_update

  lifecycle {
    prevent_destroy = false
  }
}
