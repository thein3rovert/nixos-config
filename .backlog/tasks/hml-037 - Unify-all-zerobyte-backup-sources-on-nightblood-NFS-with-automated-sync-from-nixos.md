---
id: HML-037
title: >-
  Unify all zerobyte backup sources on nightblood NFS with automated sync from
  nixos
status: To Do
assignee: []
created_date: '2026-09-08 19:54'
labels: []
milestone: Homelab
dependencies: []
references:
  - hosts/roan/configuration.nix
  - modules/nixos/services/monitoring/zerobyte/default.nix
  - modules/nixos/profiles/nfs/default.nix
  - hosts/nixos/configuration.nix
modified_files:
  - hosts/nixos/configuration.nix
  - hosts/roan/configuration.nix
priority: high
type: task
ordinal: 43000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Re-architect backups after the garage migration (HML-036) and the discovery that zerobyte's sources were stale manual copies.

CURRENT STATE (verified 2026-09-08):
- Zerobyte runs on roan (100.99.235.113, Tailscale) as a podman container (ghcr.io/nicotsx/zerobyte v0.19), config in /var/lib/containers/zerobyte/data/ironmount.db (SQLite).
- Zerobyte reads sources from nightblood NFS: roan mounts 192.168.0.105:/srv/nfs at /mnt/nightblood; sources live at /mnt/nightblood/sources/{nixos-config,thein3rovert_vault}.
- PROBLEM 1: No automated sync exists — the nightblood copies are STALE manual copies (nixos-config flake.nix mtime Sep 4, vault Sep 2) while zerobyte reports backups as successful.
- PROBLEM 2: The Garage Backup schedule (weekly, restic → cloudflare-main-backup R2 repo) sources from an NFS volume pointing at bellamy 100.105.187.63:/var/storage/garage — that export was removed in HML-036; volume status "error: Volume is not mounted", disabled.
- PROBLEM 3: The Infrastructure schedule's mirror to the s3personal repository (garage restic repo at https://s3.thein3rovert.dev, bucket thein3rovert) fails with restic "Stat: Access Denied" — pre-existing issue, likely stale credentials or missing repo in the bucket.
- Garage now runs on the nixos host (data at /var/storage/garage, 1.5G). Nightblood (192.168.0.105, NFS /srv/nfs) is the DEDICATED NFS server — nixos must NOT become an NFS server; it already mounts nightblood read-write at /mnt/nightblood.

USER DECISION: Everything goes through zerobyte (single monitoring point). All sources must land on nightblood /srv/nfs/sources/ first, pushed from nixos as an NFS client.

TARGET ARCHITECTURE:
- nixos systemd rsync timer pushes: ~/nixos-config, ~/Documents/project/thein3rovert_vault, and /var/storage/garage → /mnt/nightblood/sources/
- Zerobyte (roan) reads ALL sources from the NFS mount as container volumes → restic → R2 (cloudflare-main-backup) and garage repo (s3personal via public domain, which routes to local garage)

ACCEPTED RISK (same as pre-migration): the garage copy is a point-in-time rsync of a live garage data dir (meta+data) — not perfectly consistent, but identical semantics to the old bellamy NFS read-only mount.

RELATED: HML-035 (Migrate Zerobyte to roan and Nightblood) — In Progress; this task builds on its final state.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 A systemd rsync timer on the nixos host syncs nixos-config, thein3rovert_vault, and /var/storage/garage to nightblood /srv/nfs/sources/ on a defined schedule (e.g. every 6h or daily)
- [ ] #2 Synced copies on nightblood are verifiably fresh (mtimes/content match the nixos sources after a timer run, not stale manual copies)
- [ ] #3 Roan's zerobyte container mounts /mnt/nightblood/sources/garage as a read-only volume
- [ ] #4 Zerobyte's garage-s3-backup volume is re-pointed from the dead bellamy NFS backend to the directory backend, re-enabled, and shows status mounted
- [ ] #5 The Garage Backup schedule runs successfully end-to-end: sources from nightblood NFS, restic repository on R2 (cloudflare-main-backup)
- [ ] #6 Infrastructure and Second_Brain schedules continue to back up successfully from the same NFS sources
- [ ] #7 The s3personal mirror access-denied error is diagnosed and fixed so the Infrastructure mirror to R2 succeeds
- [ ] #8 The old bellamy NFS volume config in zerobyte is cleaned up (no dead references)
- [ ] #9 Backups visible and healthy in the zerobyte UI
<!-- AC:END -->
