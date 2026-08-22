# GCP Storage Bucket Terraform Module

This module creates a Google Cloud Storage bucket with configurable storage class, lifecycle rules, versioning, and access control.

## Features

- Configurable storage class (Standard, Nearline, Coldline, Archive)
- Versioning support for object history
- Lifecycle rules for cost optimization
- Uniform bucket-level access
- Public access prevention
- Labels for organization
- Always Free tier compatible (5GB in US regions)

## Usage

### Basic Bucket

```hcl
module "my_bucket" {
  source = "../../modules/infra/providers/gcp/storage-bucket"

  project_id  = "my-gcp-project"
  bucket_name = "my-unique-bucket-name"
  location    = "US"  # Always Free eligible

  labels = {
    environment = "production"
    managed_by  = "terraform"
  }
}
```

### Terraform State Bucket

```hcl
module "terraform_state" {
  source = "../../modules/infra/providers/gcp/storage-bucket"

  project_id         = "my-gcp-project"
  bucket_name        = "my-terraform-state"
  location           = "US"
  versioning_enabled = true
  force_destroy      = false  # Protect state from accidental deletion

  labels = {
    purpose     = "terraform-state"
    environment = "production"
  }
}
```

### With Lifecycle Rules

```hcl
module "archive_bucket" {
  source = "../../modules/infra/providers/gcp/storage-bucket"

  project_id  = "my-gcp-project"
  bucket_name = "my-archive-bucket"
  location    = "US"

  lifecycle_rules = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age = 30
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
      condition = {
        age = 90
      }
    }
  ]
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_id | GCP project ID | string | - | yes |
| bucket_name | Bucket name (globally unique) | string | - | yes |
| location | Bucket location | string | "US" | no |
| storage_class | Storage class | string | "STANDARD" | no |
| versioning_enabled | Enable versioning | bool | true | no |
| uniform_bucket_level_access | Uniform access | bool | true | no |
| public_access_prevention | Public access prevention | string | "enforced" | no |
| labels | Resource labels | map(string) | {} | no |
| lifecycle_rules | Lifecycle rules | list(object) | [] | no |
| force_destroy | Allow non-empty delete | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | The bucket name |
| bucket_url | The base URL |
| bucket_self_link | The URI |
| bucket_location | The location |

## Requirements

- Terraform >= 1.0
- Google Provider ~> 5.0
- Cloud Storage API enabled
- Globally unique bucket name

## Always Free Tier

To stay within Always Free:
- Use `location = "US"` (or us-west1, us-central1, us-east1)
- Keep total storage under 5GB
- Use STANDARD storage class
