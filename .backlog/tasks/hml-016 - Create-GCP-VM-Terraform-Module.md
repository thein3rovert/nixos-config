---
id: HML-016
title: Create GCP VM Terraform Module
status: Done
assignee: []
created_date: '2026-08-16 20:38'
updated_date: '2026-08-16 22:13'
labels:
  - terraform
  - gcp
  - infrastructure
  - module
dependencies: []
priority: high
type: feature
ordinal: 19000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Create a reusable Terraform module for deploying virtual machines to Google Cloud Platform. The module should follow the existing project structure under terraform/modules/infra/providers/gcp/vm/ and provide a similar interface to the existing Proxmox VM module.

The module will enable infrastructure-as-code deployment of GCP compute instances with configurable machine type, disk, networking, and metadata options.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Module created at terraform/modules/infra/providers/gcp/vm/ with main.tf, variables.tf, and outputs.tf
- [x] #2 Module uses google_compute_instance resource with configurable machine_type, zone, and project
- [x] #3 Variables include: project_id, zone, instance_name, machine_type, boot_disk_image, boot_disk_size, network, subnetwork, ssh_keys, tags, and metadata
- [x] #4 Outputs expose: instance_id, instance_name, internal_ip, and external_ip
- [x] #5 Module includes version constraints for google provider
- [x] #6 Module supports both static and ephemeral external IPs
- [x] #7 Module allows custom metadata and startup scripts
- [x] #8 Module follows existing project patterns from proxmox/vm module
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Successfully deployed VM to GCP using the module. VM is accessible via SSH as thein3rovert@srv-prod-01. Module integrated into terraform/envs/prod with proper provider configuration and local variable for multi-user SSH keys.

Secret Manager module created as subtask HML-016.01 and successfully deployed. Both VM and secrets management working in production.
<!-- SECTION:NOTES:END -->
