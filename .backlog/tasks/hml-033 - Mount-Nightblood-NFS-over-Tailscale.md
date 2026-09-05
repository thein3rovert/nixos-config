---
id: HML-033
title: Mount Nightblood NFS over Tailscale
status: In Progress
assignee:
  - AI
created_date: '2026-09-04 19:26'
updated_date: '2026-09-05 10:30'
labels:
  - nixos
  - nfs
  - tailscale
dependencies: []
documentation:
  - 'backlog://documents/doc-002'
modified_files:
  - hosts/nixos/configuration.nix
  - hosts/roan/configuration.nix
  - terraform/envs/prod/main.tf
priority: medium
type: enhancement
ordinal: 37000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure the NixOS workstation and roan to mount Nightblood's shared storage using its stable Tailscale address rather than LAN addressing.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The workstation mounts Nightblood's NFS share using its Tailscale IP
- [ ] #2 Roan mounts Nightblood's NFS share using its Tailscale IP
- [ ] #3 Both host configurations evaluate successfully
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Keep Nightblood's verified NFSv4 export over Tailscale. 2. Do not mount NFS inside roan: CT 103 is unprivileged, and the kernel rejects both rpc_pipefs and NFS mounts despite Proxmox `mount=nfs` relaxing LXC/AppArmor policy. 3. Mount Nightblood's export on the Proxmox host mount-weather, then bind-mount that host directory into roan using a Proxmox LXC mount point. 4. Remove/disable roan's in-guest NFS client configuration, deploy, and verify the bind-mounted share is accessible. 5. Evaluate affected configurations and record verification.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Confirmed after a full CT restart that CT 103 has `features: nesting=1,mount=nfs`, but `rpc_pipefs` still fails with permission denied and direct NFSv4 mount fails with operation not permitted. Root cause is the kernel limitation for NFS mounts from an unprivileged user-namespace LXC, not Nightblood connectivity or exports. Recommended architecture is host-side NFS mount plus bind mount into roan.

Created guide doc-002 before execution. On Nightblood, added LAN export authorization for `192.168.0.0/24` alongside the existing Tailscale range and reloaded exports. On mount-weather, verified `nfs-common`, mounted `192.168.0.105:/srv/nfs` at `/mnt/nightblood`, added persistent systemd automount entry to `/etc/fstab`, attached it to CT 103 as `mp0`, and rebooted roan. Verified inside roan that `/mnt/nightblood` is a mountpoint and contains Nightblood's `lost+found`. The old in-guest NFS configuration remains active from the failed deployment and leaves `var-lib-nfs-rpc_pipefs.mount` failed; it must be disabled in roan's NixOS config and redeployed.
<!-- SECTION:NOTES:END -->
