---
id: HML-004
title: Pin DeterminateSystems nix-installer-action version
status: To Do
assignee: []
created_date: '2026-08-01 21:31'
labels:
  - ci
  - nix
  - github-actions
dependencies: []
priority: medium
ordinal: 3000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Currently using @main which caused silent upgrade to Nix 3.0 breaking CI. Pin to a stable version to prevent future breakage.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Workflow pins nix-installer-action to specific version
- [ ] #2 CI runs consistently across builds
<!-- AC:END -->
