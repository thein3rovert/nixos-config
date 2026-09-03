---
id: HML-024
title: Remap backslash key to slash with Kanata
status: Done
assignee: []
created_date: '2026-09-01 22:25'
updated_date: '2026-09-01 22:25'
labels:
  - nixos
  - keyboard
  - kanata
dependencies: []
modified_files:
  - hosts/nixos/configuration.nix
priority: low
type: enhancement
ordinal: 28000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Configure the NixOS host so the physical backslash key produces a forward slash consistently, with Kanata managed declaratively as a system service.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The physical backslash key outputs a forward slash
- [x] #2 Kanata starts automatically as a managed NixOS service
- [x] #3 The Kanata configuration passes validation
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Identify the physical key code.
2. Configure the native NixOS Kanata service with the remapping.
3. Validate the generated configuration and rebuild the host.
4. Confirm the remapping works interactively.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
evtest identified the physical key as KEY_BACKSLASH (code 43). The native NixOS services.kanata module was selected so uinput permissions and service lifecycle are managed declaratively. Kanata config validation passed, NixOS evaluation succeeded, and the user confirmed the key now outputs a forward slash.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Enabled the native NixOS Kanata service and configured the physical backslash key to emit a forward slash. The generated Kanata configuration passed validation, the NixOS configuration evaluated successfully, and the user confirmed the remapping works after rebuilding.
<!-- SECTION:FINAL_SUMMARY:END -->
