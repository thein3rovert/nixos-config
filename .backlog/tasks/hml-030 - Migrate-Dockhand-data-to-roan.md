---
id: HML-030
title: Migrate Dockhand data to roan
status: Done
assignee:
  - AI
created_date: '2026-09-04 17:06'
updated_date: '2026-09-04 19:13'
labels:
  - podman
  - dockhand
  - migration
  - nixos
dependencies: []
references:
  - modules/nixos/services/monitoring/dockhand/default.nix
priority: medium
type: task
ordinal: 34000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Move Dockhand's persistent application state from the workstation to the new NixOS application LXC named roan while retaining the source copy for rollback.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Dockhand persistent data is copied to roan without changing the source copy
- [x] #2 The copied data retains the files and permissions needed by Dockhand
- [x] #3 The source Dockhand service remains stopped to prevent divergent state until cutover is verified
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Stop the source Dockhand systemd service and confirm the container is no longer running.
2. Create a stable Dockhand data directory on roan.
3. Stream an ownership-preserving tar archive of the source named-volume contents over SSH.
4. Compare source and destination file counts and sizes while leaving the source stopped and intact.

Fix the Dockhand module's malformed port mapping (`3000:latest`) to map host port 3000 to container port 3000, then rebuild roan and verify the service.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Stopped `podman-dockhand.service` on the workstation and streamed the contents of `/var/lib/containers/storage/volumes/dockhand_data/_data` to `/var/lib/containers/dockhand` on roan using numeric-owner-preserving tar over SSH. Both source and destination report 201001736 bytes and 8 filesystem entries. Destination root ownership is 1001:1001 mode 0755. The source unit remains stopped/failed and source data remains intact.

After fixing the Dockhand port mapping and image tag, the service is active on roan, the container reports Up, port 3000 is published, and HTTP returns 307. The source workstation service remains stopped.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Migrated Dockhand's 201001736-byte persistent dataset to roan with ownership preserved, corrected the container port mapping and image tag, and verified the service is active and responds over HTTP. The original workstation copy remains intact and stopped for rollback.
<!-- SECTION:FINAL_SUMMARY:END -->
