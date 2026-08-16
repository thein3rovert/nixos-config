# GCP VM Terraform Module

This module creates a Google Cloud Compute Engine VM instance with configurable networking, disk, and metadata options.

## Features

- Configurable machine type, zone, and project
- Flexible boot disk configuration (image, size, type)
- Support for both ephemeral and static external IPs
- Custom metadata and startup scripts
- Network tags for firewall rules
- SSH key management
- Resource labels for organization

## Usage

```hcl
module "web_server" {
  source = "../../modules/infra/providers/gcp/vm"

  project_id    = "my-gcp-project"
  zone          = "us-central1-a"
  instance_name = "web-server-01"
  machine_type  = "e2-medium"

  boot_disk_image = "ubuntu-os-cloud/ubuntu-2204-lts"
  boot_disk_size  = 30

  network    = "default"
  subnetwork = null

  enable_external_ip = true

  ssh_keys = "myuser:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB..."

  tags = ["web", "http-server", "https-server"]

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }

  metadata = {
    enable-oslogin = "TRUE"
  }

  startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
  EOF
}

output "web_server_ip" {
  value = module.web_server.external_ip
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| zone | GCP zone | string | - | yes |
| instance_name | Name of the VM instance | string | - | yes |
| machine_type | Machine type | string | "e2-medium" | no |
| boot_disk_image | Boot disk image | string | "debian-cloud/debian-11" | no |
| boot_disk_size | Boot disk size in GB | number | 20 | no |
| boot_disk_type | Boot disk type | string | "pd-balanced" | no |
| network | VPC network name | string | "default" | no |
| subnetwork | VPC subnetwork name | string | null | no |
| enable_external_ip | Whether to assign external IP | bool | true | no |
| static_external_ip | Static external IP address | string | null | no |
| ssh_keys | SSH public keys | string | "" | no |
| tags | Network tags | list(string) | [] | no |
| labels | Resource labels | map(string) | {} | no |
| metadata | Custom metadata | map(string) | {} | no |
| startup_script | Startup script | string | null | no |

## Outputs

| Name | Description |
|------|-------------|
| instance_id | Server-assigned unique identifier |
| instance_name | Name of the instance |
| internal_ip | Internal IP address |
| external_ip | External IP address (null if not assigned) |
| self_link | URI of the created resource |

## Requirements

- Terraform >= 1.0
- Google Provider ~> 5.0
- Appropriate GCP credentials and permissions
