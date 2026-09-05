---
id: HML-035
title: Migrate Zerobyte to roan and Nightblood
status: In Progress
assignee:
  - AI
created_date: '2026-09-05 10:38'
updated_date: '2026-09-05 10:50'
labels:
  - zerobyte
  - podman
  - nfs
  - migration
dependencies: []
modified_files:
  - hosts/nixos/configuration.nix
  - hosts/roan/configuration.nix
  - modules/nixos/services/monitoring/zerobyte/default.nix
priority: high
type: task
ordinal: 39000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Move Zerobyte application state from the workstation to roan and place its backup source datasets on Nightblood so the service no longer depends on workstation-local bind mounts.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Zerobyte application state is copied to roan with the source retained for rollback
- [ ] #2 The NixOS configuration and Obsidian vault source datasets are copied to Nightblood
- [ ] #3 Roan Zerobyte uses Nightblood-backed source paths
- [ ] #4 Zerobyte runs successfully on roan
- [ ] #5 The workstation Zerobyte instance remains stopped to avoid divergent state
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Stop Zerobyte on the workstation to freeze application state.
2. Copy Zerobyte state to `/var/lib/containers/zerobyte` on roan with ownership preserved.
3. Create source directories on Nightblood and copy the workstation NixOS config and Obsidian vault through the workstation's mounted share.
4. Configure Zerobyte on roan with its state path local to roan and source paths under `/mnt/nightblood`.
5. Deploy roan, verify Zerobyte and its mounted datasets, and leave the workstation instance disabled/stopped with original data retained.

Zerobyte requires `/dev/fuse`. Enable Proxmox LXC FUSE support on roan as root while preserving nesting and NFS mount features, represent those settings in Terraform to avoid drift, restart roan, and retry Zerobyte.
<!-- SECTION:PLAN:END -->
