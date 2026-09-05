---
id: HML-029
title: Provision NixOS application LXC with Terraform
status: Done
assignee:
  - AI
created_date: '2026-09-03 20:41'
updated_date: '2026-09-04 19:13'
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
- [x] #1 The NixOS application LXC runs on the selected Proxmox cluster node
- [x] #2 The LXC supports nested Podman workloads
- [x] #3 The LXC is allocated 2 CPU cores 2 GB RAM 1 GB swap and a 20 GB root disk
- [x] #4 Terraform configuration validates and existing LXC state addresses migrate without recreation
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

Provisioned roan as LXC 103 on mount-weather. Due to Proxmox permissions, keyctl was omitted while nesting remains enabled. Terraform moved blocks safely renamed the shared LXC resource; full plan showed no existing resource destruction. Dockhand is active on roan and responds on port 3000.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Provisioned the NixOS application LXC on mount-weather with reusable cluster placement configuration, nested Podman support, and the requested resources. Generalized the shared LXC resource name with safe state migration and removed a misleading disk-message provisioner. Verified Terraform configuration and confirmed Dockhand runs successfully on roan.
<!-- SECTION:FINAL_SUMMARY:END -->
