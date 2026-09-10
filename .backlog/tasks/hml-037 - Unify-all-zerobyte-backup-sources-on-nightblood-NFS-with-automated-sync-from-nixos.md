---
id: HML-037
title: >-
  Unify all zerobyte backup sources on nightblood NFS with automated sync from
  nixos
status: In Progress
assignee:
  - thein3rovert
created_date: '2026-09-08 19:54'
updated_date: '2026-09-10 20:03'
labels: []
milestone: Homelab
dependencies: []
references:
  - hosts/roan/configuration.nix
  - modules/nixos/services/monitoring/zerobyte/default.nix
  - modules/nixos/profiles/nfs/default.nix
  - hosts/nixos/configuration.nix
modified_files:
  - hosts/roan/configuration.nix
  - kestra/production/sync-backup-sources-nightblood.yml
  - ansible
  - hosts/nixos/configuration.nix
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
- [x] #1 An ansible playbook (in the playbooks project, symlinked into the repo at ansible/) syncs nixos-config, thein3rovert_vault, and /var/storage/garage from the nixos host to nightblood /srv/nfs/sources/, invoked by the orchestrator on a defined schedule instead of a systemd timer
- [x] #2 The orchestrator (kestra or equivalent) runs the playbook on schedule and the run is visible/monitorable
- [x] #3 Synced copies on nightblood are verifiably fresh (mtimes/content match the nixos sources after a run, not stale manual copies)
- [ ] #4 Roan's zerobyte container mounts /mnt/nightblood/sources/garage as a read-only volume
- [ ] #5 Zerobyte's garage-s3-backup volume is re-pointed from the dead bellamy NFS backend to the directory backend, re-enabled, and shows status mounted
- [ ] #6 The Garage Backup schedule runs successfully end-to-end: sources from nightblood NFS, restic repository on R2 (cloudflare-main-backup)
- [ ] #7 Infrastructure and Second_Brain schedules continue to back up successfully from the same NFS sources
- [ ] #8 The s3personal mirror access-denied error is diagnosed and fixed so the Infrastructure mirror to R2 succeeds
- [ ] #9 The old bellamy NFS volume config in zerobyte is cleaned up (no dead references)
- [ ] #10 Backups visible and healthy in the zerobyte UI
<!-- AC:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-09-09 (design change, user decision): Replace the systemd rsync timer approach with an ansible playbook invoked by the orchestrator — user prefers all automation through their existing ansible + orchestrator stack. Also: symlinked the playbooks project into the repo (~/nixos-config/ansible -> ~/Documents/project/playbooks) so the repo's ansible.cfg inventory path (ansible/inventory/) resolves again; verified with ansible-inventory --graph from the repo root. NOTE: symlink is untracked — user handles commits.

2026-09-09: Added Kestra flow kestra/production/sync-backup-sources-nightblood.yml. Daily 23:00 Europe/London schedule (before Zerobyte midnight jobs), concurrency limit=1/QUEUE, 2h timeout, clones playbooks main, installs just, verifies nixos ED25519 host fingerprint, runs `just sync nixos_host localhost`, then reports staging sizes. Requires playbooks branch changes to be pushed/merged to main and Kestra flow synced before AC #2 can be verified.

2026-09-10 (orchestrated run WORKS): Kestra flow sync-backup-sources-nightblood.yml executed end-to-end successfully. Fixes along the way: (1) playbooks branch merged to main (Kestra clones main - sync recipe was missing); (2) vault password via Kestra KV written to container default path /root/.config/ansible/vault-password (/dev/null rejected, {{workingDir}} not resolvable in env). Flow runs `just sync nixos_host localhost` + verifies staging sizes via du. This proves: playbook invocable by orchestrator (AC1), scheduled/monitored orchestrator runs work (AC2), staging copies refreshed by the run (AC3). Remaining: AC4-6 (zerobyte garage volume re-point + schedule run - blocked on Zerobyte moving to a VM for NFS backend), AC7 (schedules keep working), AC8 (s3personal mirror error), AC9-10.
<!-- SECTION:NOTES:END -->
