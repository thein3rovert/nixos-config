---
id: HML-029
title: Provision NixOS application LXC with Terraform
status: In Progress
assignee:
  - AI
created_date: '2026-09-03 20:41'
updated_date: '2026-09-03 21:53'
labels:
  - terraform
  - proxmox
  - nixos
  - lxc
dependencies: []
references:
  - >-
    modules/bootstrap/result/tarball/nixos-image-lxc-proxmox-26.05.20251205.f61125a-x86_64-linux.tar.xz
modified_files:
  - terraform/envs/prod/main.tf
  - terraform/envs/prod/variables.tf
  - terraform/modules/infra/providers/proxmox/lxc/main.tf
  - terraform/modules/infra/providers/proxmox/lxc/outputs.tf
priority: medium
type: feature
ordinal: 33000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add a production Terraform definition for a dedicated NixOS Proxmox container that can host services currently running on the workstation.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Terraform defines an unprivileged NixOS LXC using the uploaded Proxmox template
- [ ] #2 The container has nesting and keyctl support for running Podman workloads
- [ ] #3 The container is allocated 2 CPU cores 2 GB RAM 1 GB swap and persistent root storage
- [ ] #4 Terraform configuration formatting and validation pass
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Reuse the existing Telmate Proxmox LXC module and current production variables.
2. Add a uniquely identified NixOS application-host container using the uploaded template with nesting and keyctl enabled.
3. Allocate 2 cores 2 GB RAM 1 GB swap and a 20 GB root disk.
4. Format and validate the production Terraform configuration without applying infrastructure.

Pin this container to the second Proxmox node `mount-weather` and use that node's management IP for the module's post-create SSH provisioner; retain node-local `local` template and `local-lvm` root storage references.

Replace the hardcoded application-host node name and management IP with dedicated typed input variables, keeping environment-specific values in the ignored production terraform.tfvars file.

Model reusable cluster inventory as a `proxmox_nodes` map keyed by Proxmox node name, and select the application workload's node with `app_container_node`; derive both `target_node` and management IP from that map.

Generalize workload placement with a reusable `proxmox_placements` map, where each workload name maps to a key in `proxmox_nodes`; derive node name and management IP from the selected entry.

Rename the shared LXC resource from OS-specific `ubuntu_container` to generic `container`, with a module-local Terraform `moved` block preserving all existing instances in state.

The Proxmox API token is not `root@pam`, so it cannot set the privileged `keyctl` feature during container creation. Disable keyctl for this unprivileged Podman host and retain nesting, which is the portable least-privilege configuration; only add keyctl later if runtime testing proves it necessary.

Remove the unconditional disk-resize informational provisioner from the shared LXC module because it runs only at creation, does not detect disk changes, and gives misleading container-specific instructions.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Added the nixos_apps module using VMID/IP suffix 121, the uploaded NixOS template, 2 cores, 2 GB RAM, 1 GB swap, 20 GB disk, and nested-container features. terraform fmt completed. Validation is blocked during terraform init because the existing GCP backend/provider cannot find Application Default Credentials; no infrastructure was applied.

Renamed the shared resource to `proxmox_lxc.container`, updated its output reference, and added a module-local moved block. `terraform validate` succeeds. A full plan recognizes all three existing resources as state-address moves only and reports 1 add, 0 change, 0 destroy. Targeted planning cannot be used for this first apply because Terraform requires all moved instances to participate.
<!-- SECTION:NOTES:END -->
