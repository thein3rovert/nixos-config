---
id: HML-006
title: Monitor Determinate Nix for libgit2 SSH fix
status: To Do
assignee: []
created_date: '2026-08-01 21:31'
labels:
  - ci
  - nix
  - tech-debt
dependencies: []
priority: low
ordinal: 5000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Track upstream progress on libgit2 SSH auth fix in DeterminateSystems/nix-src. Once fixed, remove pre-clone workaround from CI workflow and restore native flake fetching with polis input. Related to NixOS/nix#9133.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Determinate Nix issue tracker checked quarterly
- [ ] #2 Pre-clone workaround removed when fix lands
- [ ] #3 Flake lock reproducibility restored
<!-- AC:END -->
