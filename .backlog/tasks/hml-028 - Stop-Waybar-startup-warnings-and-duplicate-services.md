---
id: HML-028
title: Stop Waybar startup warnings and duplicate services
status: Done
assignee:
  - opencode
created_date: '2026-09-03 19:30'
updated_date: '2026-09-05 10:15'
labels:
  - hyprland
  - waybar
dependencies: []
references:
  - /home/thein3rovert/.config/hypr/start.sh
  - /home/thein3rovert/.config/waybar/config
modified_files:
  - /home/thein3rovert/.config/hypr/start.sh
  - /home/thein3rovert/.config/waybar/config
priority: medium
type: bug
ordinal: 37000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the Hyprland startup flow and Waybar configuration so manually or automatically launching the startup script does not attach noisy processes to the terminal, start duplicate desktop services, or enable the inaccessible keyboard-state module.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 Running the startup script does not start duplicate Waybar Dunst or nm-applet processes
- [ ] #2 Waybar output is detached from the invoking terminal
- [ ] #3 The inaccessible keyboard-state module is disabled
- [ ] #4 The modified startup and Waybar configuration files pass syntax validation
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Make start.sh idempotent by checking each desktop process before launching it.
2. Redirect background process output away from the invoking terminal so Waybar and related service logs do not pollute the shell.
3. Remove keyboard-state from the active Waybar module list to eliminate inaccessible /dev/input warnings without broadening device permissions.
4. Validate shell syntax and Waybar JSONC parsing, then restart Waybar detached to apply the change.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Updated start.sh with pgrep guards for nm-applet, Waybar, and Dunst; all service output is redirected away from the invoking terminal. Disabled keyboard-state in the active Waybar config rather than granting broad input-device access. Bash syntax and parsed JSONC validation pass. This shell cannot restart the user's graphical-session processes because it lacks the active Wayland/Hyprland environment, so runtime confirmation remains pending.
<!-- SECTION:NOTES:END -->
