---
id: HML-031
title: Provision local NFS storage LXC
status: Done
assignee:
  - AI
created_date: '2026-09-04 17:42'
updated_date: '2026-09-08 19:38'
labels:
  - terraform
  - proxmox
  - nixos
  - nfs
  - storage
dependencies: []
modified_files:
  - terraform/envs/prod/main.tf
  - terraform/envs/prod/terraform.tfvars
  - terraform/modules/infra/providers/proxmox/lxc/main.tf
  - terraform/modules/infra/providers/proxmox/lxc/variables.tf
priority: medium
type: feature
ordinal: 41000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Add production Terraform infrastructure for a lightweight NixOS NFS container on the primary Proxmox node, backed by a dedicated 100 GB data volume on the 1 TB HDD storage pool.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Terraform defines an Ubuntu NFS VM on the primary Proxmox node
- [x] #2 The VM has a separate 100 GB data disk on LVM_MAIN
- [x] #3 The VM uses lightweight CPU and memory allocations appropriate for NFS
- [x] #4 The existing Nightblood LXC remains intact during parallel migration
- [x] #5 Terraform configuration formatting and validation pass without changing existing resources
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Extend the shared Proxmox VM module with an optional second data disk.
2. Add a parallel Ubuntu VM named nightblood-vm on the primary Proxmox node using VMID/IP 105.
3. Allocate 1 CPU 1 GB RAM a 20 GB root disk and a separate 100 GB data disk on LVM_MAIN.
4. Keep the existing Nightblood LXC intact until the VM is configured and tested.
5. Validate and inspect the full Terraform plan before applying.

Rebuild broken Proxmox Ubuntu cloud template VM 9000 from the current Ubuntu 24.04 LTS cloud image, preserving its template name so existing Terraform clone references remain valid.

Remove the obsolete NixOS Nightblood host configuration and Colmena node entry now that Ubuntu VM 105 has replaced LXC 104.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Extended the shared Telmate Proxmox LXC module with optional dynamic mount points. Added `nfs_storage` as VMID 104 on the primary `thein3rovert` node with IP 192.168.0.104/24, 1 CPU, 512 MB RAM, 512 MB swap, an 8 GB root disk on local-lvm, and a separate 100 GB `/srv/nfs` volume on LVM_MAIN. Terraform initialized and validated successfully; the full plan reports exactly 1 add, 0 change, 0 destroy.

Replaced the unsuitable NixOS LXC design with Ubuntu VM 105 named nightblood. Rebuilt the broken Ubuntu cloud template, provisioned the VM, attached and mounted the 100 GB /dev/sdb data disk, and configured an active NFS export using the reusable Ansible role. Destroyed obsolete LXC 104 after the VM was operational.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Provisioned Ubuntu VM 105 as Nightblood with an 8 GB OS disk and separate 100 GB LVM_MAIN data disk. Configured and verified /srv/nfs through the reusable Ansible NFS role, then removed the obsolete NixOS LXC after confirming the VM approach. Terraform validates and the VM remains managed as module.nfs_storage.
<!-- SECTION:FINAL_SUMMARY:END -->
