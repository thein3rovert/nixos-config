---
id: HML-032
title: Fix NFS profile option recursion
status: Done
assignee:
  - AI
created_date: '2026-09-04 18:28'
updated_date: '2026-09-04 18:30'
labels:
  - nixos
  - nfs
dependencies: []
modified_files:
  - modules/nixos/profiles/nfs/default.nix
priority: high
type: bug
ordinal: 36000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Ensure NFS server and client roles evaluate independently so Nightblood can enable the NFS server without causing Nix module recursion.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Nightblood configuration evaluates without infinite recursion
- [x] #2 Existing explicit NFS server and client role selections remain supported
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Remove the self-referential backward-compatibility assignments that inspect and define isServer/isClient simultaneously.
2. Preserve explicit server/client configuration through the existing boolean options.
3. Evaluate Nightblood and other affected hosts to verify the recursion is gone.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Removed self-referential compatibility assignments that simultaneously read and defined the NFS role options. Evaluated the Colmena Nightblood and Bellamy nodes successfully; both explicit server configurations resolve to services.nfs.server.enable = true.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Fixed infinite recursion in the reusable NFS profile by removing the self-referential role defaults. Explicit server and client selections remain supported, and both Nightblood and Bellamy server configurations now evaluate successfully.
<!-- SECTION:FINAL_SUMMARY:END -->
