---
id: HML-027
title: Migrate Hyprland wallpaper commands to awww
status: In Progress
assignee:
  - opencode
created_date: '2026-09-03 19:24'
updated_date: '2026-09-03 19:38'
labels:
  - hyprland
  - wallpaper
  - awww
dependencies: []
references:
  - /home/thein3rovert/.config/hypr/hyprland.lua
  - /home/thein3rovert/.config/hypr/start.sh
  - /home/thein3rovert/.config/hypr/external/swww/set-random-wallpaper.sh
modified_files:
  - /home/thein3rovert/.config/hypr/hyprland.lua
  - /home/thein3rovert/.config/hypr/start.sh
  - /home/thein3rovert/.config/hypr/external/swww/set-random-wallpaper.sh
priority: medium
type: bug
ordinal: 31000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Update the active Hyprland Lua configuration and wallpaper scripts to use the installed awww replacement so the wallpaper daemon starts correctly and wallpaper-changing shortcuts work again.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 The active Hyprland configuration starts the awww daemon instead of swww
- [ ] #2 The startup script displays the configured initial wallpaper using awww
- [ ] #3 The random wallpaper shortcut invokes awww successfully
- [ ] #4 No active wallpaper command depends on the unavailable swww executable
- [ ] #5 Modified shell and Lua files pass syntax validation
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Replace active swww daemon and image commands in the native Hyprland Lua config and startup script with their awww equivalents.
2. Rename active SWWW transition environment variables to AWWW equivalents.
3. Update the random-wallpaper script to invoke `awww img` while leaving its existing directory layout intact.
4. Validate Lua and shell syntax and verify no active commands still invoke swww; runtime wallpaper display will be tested from the active Hyprland session.

Make startup wallpaper selection dynamic because the random-wallpaper script rotates files between current-wallpaper and enabled-wallpapers, so no fixed filename is stable. Also make start.sh start awww-daemon only when absent so it works safely when run manually.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Replaced the active daemon with `awww-daemon`, changed image commands to `awww img`, renamed transition variables to AWWW_*, and corrected the random-wallpaper script shebang to Bash because it uses arrays and RANDOM. Avoided starting the daemon twice: hyprland.lua owns daemon startup and start.sh waits before setting the initial image. Lua and Bash syntax checks pass, `awww img --help` confirms all retained options and environment variables are supported, and no active swww commands remain.
<!-- SECTION:NOTES:END -->
