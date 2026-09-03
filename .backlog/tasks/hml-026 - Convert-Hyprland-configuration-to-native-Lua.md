---
id: HML-026
title: Convert Hyprland configuration to native Lua
status: Done
assignee:
  - opencode
created_date: '2026-09-03 19:09'
updated_date: '2026-09-03 19:17'
labels:
  - hyprland
  - lua
dependencies: []
references:
  - /home/thein3rovert/.config/hypr/hyprland.conf.bak
  - /home/thein3rovert/.config/hypr/hyprland.lua
modified_files:
  - /home/thein3rovert/.config/hypr/hyprland.lua
priority: medium
type: task
ordinal: 30000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Convert the existing Hyprland configuration at /home/thein3rovert/.config/hyprland/hyprland.conf.bak into a native Lua configuration while preserving the backup unchanged and retaining equivalent behavior.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 The hyprland.conf.bak file remains unchanged
- [x] #2 A native hyprland.lua configuration is produced from the backed-up configuration
- [x] #3 Monitors settings keybindings rules environment variables and startup commands retain equivalent behavior
- [x] #4 The resulting Lua configuration passes available Hyprland configuration validation without errors
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Preserve ~/.config/hypr/hyprland.conf.bak byte-for-byte and use it as the sole behavior source.
2. Replace ~/.config/hypr/hyprland.lua with native Hyprland 0.55 Lua equivalents for monitor setup, startup commands, environment, configuration sections, animations, devices, keybindings, and enabled window rules.
3. Inline active behavior from the legacy swww and rofi source files; omit commented examples and the malformed unnamed empty-class rule.
4. Validate Lua syntax and confirm the active Hyprland session reloads the configuration with no reported config errors.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Located the actual files under ~/.config/hypr rather than ~/.config/hyprland. The backup and target Lua file both exist.

Converted the backup into native hl.* Lua API calls in ~/.config/hypr/hyprland.lua. Included active settings from external swww/rofi sources directly because Lua does not consume legacy .conf sources. Lua loadfile syntax validation passed. Backup SHA-256 remained b44ebab022c13dfff2731a206b5b151ce8e490c0272deb5a8c585b1f5a24a8d6. Runtime reload could not be performed from this shell because HYPRLAND_INSTANCE_SIGNATURE is unset and no active Hyprland IPC socket is available.

User manually ran `hyprctl reload && hyprctl configerrors` from the active Hyprland session. The command returned `ok` with no configuration errors.
<!-- SECTION:NOTES:END -->

## Final Summary

<!-- SECTION:FINAL_SUMMARY:BEGIN -->
Converted the active Hyprland configuration from the backed-up Hyprlang format to the native Hyprland 0.55 Lua API in `~/.config/hypr/hyprland.lua`. Preserved monitor settings, environment variables, autostart commands, appearance and input configuration, animations, keybindings, active external swww/rofi behavior, and enabled window rules. The original `hyprland.conf.bak` remained unchanged with SHA-256 `b44ebab022c13dfff2731a206b5b151ce8e490c0272deb5a8c585b1f5a24a8d6`. Verification included successful Lua syntax loading and a user-run `hyprctl reload && hyprctl configerrors`, which returned `ok`.
<!-- SECTION:FINAL_SUMMARY:END -->
