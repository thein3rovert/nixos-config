---
id: HML-022
title: Sync Postgres Backups to GCS Bucket
status: Done
assignee: []
created_date: '2026-08-22 23:00'
updated_date: '2026-08-23 20:53'
labels:
  - nixos
  - postgres
  - backup
  - gcs
  - automation
dependencies: []
priority: high
type: feature
ordinal: 25000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create an Ansible playbook to sync Postgres backups from /var/backup/postgresql/ to Google Cloud Storage. The system already creates local backups via services.postgresqlBackup to /var/backup/postgresql/ daily at 03:10 AM.

The playbook will be executed by Kestra on schedule for centralized workflow orchestration and monitoring.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Ansible playbook created to sync backups from /var/backup/postgresql/ to gs://iv3-infra-us-prod/postgres-backups/
- [x] #2 Playbook can be scheduled via Kestra or run manually
- [x] #3 GCS authentication configured (service account key or gcloud auth)
- [x] #4 Playbook includes tasks for: listing local backups, uploading to GCS, verifying upload, cleanup old backups
- [x] #5 Retention policy implemented (e.g., delete backups older than 30 days)
- [x] #6 Error handling and idempotency
- [x] #7 Dry-run mode for testing
- [x] #8 Restore playbook documented for disaster recovery
- [x] #9 Kestra workflow created at kestra/production/postgres-backup-gcs-sync.yml
- [x] #10 Workflow fetches GCP service account JSON from Kestra KV store
- [x] #11 Workflow injects credentials to bellamy via SSH during execution
- [x] #12 Workflow cleans up credentials after ansible completes
- [x] #13 Scheduled trigger configured for daily 03:15 AM
- [x] #14 Verification task confirms all database backups uploaded
- [x] #15 Setup documentation created with KV store configuration guide
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Created postgres-gcs-backup role following existing Ansible role pattern:
- roles/postgres-gcs-backup/
  - tasks/main.yml (orchestrates backup workflow)
  - tasks/check-prerequisites.yml (validates gsutil, service account key)
  - tasks/upload-to-gcs.yml (uploads backups to GCS)
  - tasks/verify-uploads.yml (verifies all databases uploaded)
  - tasks/cleanup-old-backups.yml (30-day retention policy)
  - defaults/main.yml (configurable variables)
  - README.md (role documentation)
  - USAGE.md (comprehensive usage guide)

Role added to site.yml with tags: postgres-backup, backup, gcs

Simple playbook created: playbooks/postgres-backup-sync.yml

Usage:
- ansible-playbook site.yml --tags postgres-backup
- ansible-playbook playbooks/postgres-backup-sync.yml
- Can override variables: -e "retention_days=7"

GCS authentication via service account key at /root/.gcp/terraform-key.json
Estimated cost: $0.00/month (within free tier)

Kestra workflow created following existing pattern from k3s-cluster-inventory.yml

Workflow uses Option 1 architecture: Kestra pulls GCP JSON from KV store and injects to bellamy at runtime

Security: Credentials copied via SSH only during execution, cleaned up immediately after

Workflow includes verification task to confirm all 4 databases uploaded to GCS

Comprehensive setup guide created: README-postgres-backup-setup.md

Ready to deploy - just need to add GCP_SERVICE_ACCOUNT_JSON to Kestra KV store
<!-- SECTION:NOTES:END -->
