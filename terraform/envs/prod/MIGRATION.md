# Terraform State Migration: S3 (Garage) → GCS

## Current State
- Backend: Custom on-prem S3 (Garage) at `s3.thein3rovert.dev`
- Bucket: `thein3rovert-bucket`
- State file: `terraform-state/prod/terraform-state.tfstate`

## Target State
- Backend: Google Cloud Storage (GCS)
- Bucket: `iv3-infra-us-prod`
- Location: `US` (Always Free tier)
- Versioning: Enabled
- Purpose: Infrastructure storage (Terraform state, configs, backups)

## Prerequisites

1. **Create the GCS bucket first** (bootstrap phase):
   ```bash
   cd terraform/envs/prod
   
   # Bucket name already set in terraform.tfvars:
   # gcp_infra_bucket_name = "iv3-infra-us-prod"
   
   # Deploy the bucket (while still using S3 backend)
   terraform init
   terraform apply
   ```

2. **Verify bucket exists**:
   ```bash
   gsutil ls gs://iv3-infra-us-prod
   ```

## Migration Steps

### Step 1: Backup Current State
```bash
cd terraform/envs/prod

# Download current state from S3
terraform state pull > backup-state-$(date +%Y%m%d-%H%M%S).json

# Store backup safely
cp backup-state-*.json ~/backups/terraform/
```

### Step 2: Update Backend Configuration

Replace `backend.tf` content:

```hcl
terraform {
  backend "gcs" {
    bucket = "iv3-infra-us-prod"
    prefix = "terraform-state/prod"
  }
}
```

### Step 3: Migrate State

```bash
# Reinitialize with new backend
terraform init -migrate-state

# Terraform will prompt:
# "Do you want to copy existing state to the new backend?"
# Answer: yes

# Verify migration
terraform state list
```

### Step 4: Verify State in GCS

```bash
# Check state file exists in GCS
gsutil ls gs://iv3-infra-us-prod/terraform-state/prod/

# Download and verify
gsutil cat gs://iv3-infra-us-prod/terraform-state/prod/default.tfstate | jq .version
```

### Step 5: Test Operations

```bash
# Refresh state
terraform refresh

# Plan (should show no changes)
terraform plan

# If all looks good, you're migrated!
```

## Rollback Plan

If migration fails, restore from backup:

```bash
# Switch back to S3 backend in backend.tf
git checkout backend.tf

# Reinitialize
terraform init -reconfigure

# Push backup state
terraform state push backup-state-YYYYMMDD-HHMMSS.json

# Verify
terraform state list
```

## Post-Migration

1. **Delete old S3 state** (optional, after confirming GCS works):
   ```bash
   # Only after successful migration and testing!
   # aws s3 rm s3://thein3rovert-bucket/terraform-state/prod/terraform-state.tfstate
   ```

2. **Update documentation** to reference GCS backend

3. **Monitor GCS usage** (should be <1MB, well within free tier)

## Benefits of GCS Backend

- ✅ Native GCP integration
- ✅ Automatic versioning (state history)
- ✅ No additional infrastructure to maintain
- ✅ Always Free tier (5GB)
- ✅ Better latency when deploying GCP resources
- ✅ State locking with GCS backend

## Notes

- GCS backend uses Google Application Default Credentials (same as provider)
- State locking is automatic with GCS backend
- Versioning is enabled on the bucket for state history
- `force_destroy = false` protects against accidental deletion
