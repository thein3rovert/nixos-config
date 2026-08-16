# GCP Secret Manager Terraform Module

This module creates a Google Cloud Secret Manager secret with a version, configured for Always Free tier compatibility.

## Features

- Auto replication (Always Free compatible)
- Secure secret storage
- Resource labels for organization
- Sensitive variable handling

## Usage

```hcl
module "tailscale_secret" {
  source = "../../modules/infra/providers/gcp/secret-manager"

  project_id  = "my-gcp-project"
  secret_id   = "tailscale-authkey"
  secret_data = var.tailscale_authkey

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| secret_id | The secret ID (name) | string | - | yes |
| secret_data | The secret data to store | string (sensitive) | - | yes |
| labels | Labels to apply | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| secret_id | The secret ID |
| secret_name | Full resource name of the secret |
| secret_version_name | Full resource name of the secret version |

## Requirements

- Terraform >= 1.0
- Google Provider ~> 5.0
- Secret Manager API enabled in GCP project
