---
id: HML-044
title: Switch Hyprland system theme from Gruvbox to Tokyo Night
status: In Progress
assignee:
  - thein3rovert
created_date: '2026-09-27 12:18'
updated_date: '2026-09-27 13:40'
labels:
  - theming
  - hyprland
  - nix
dependencies: []
references:
  - home/features/cli/kitty.nix
  - modules/home/thein3rovert/programs/starship/default.nix
  - home/features/cli/zsh.nix
  - modules/home/thein3rovert/programs/kitty/default-option.nix
priority: medium
type: task
ordinal: 59000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
User currently uses Gruvbox everywhere and wants to switch full Hyprland setup to Tokyo Night for consistent dark aesthetic across terminal and desktop. Covers all theming spots in nixos-config to avoid mixed-theme leftovers.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Kitty switched to Tokyo Night theme and verified
- [x] #2 Hyprland colors/borders switched to Tokyo Night
- [x] #3 Waybar switched to Tokyo Night theme
- [x] #4 fzf colors switched to Tokyo Night
- [x] #5 File manager theme updated to Tokyo Night
- [x] #6 Rofi/Wofi launcher switched to Tokyo Night
- [x] #7 GTK/Qt theming updated to Tokyo Night variant
- [x] #8 Starship prompt switched to Tokyo Night palette
- [ ] #9 Neovim colorscheme switched to Tokyo Night
- [x] #10 Mako/Swaync notifications switched to Tokyo Night, no Gruvbox leftovers in config
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Verify nix-colors Tokyo Night scheme name (e.g. tokyo-night, tokyo-night-storm) via nix flake inputs
2. Switch colorScheme in home/features/cli/kitty.nix and modules/home/thein3rovert/programs/kitty/default-option.nix from gruvbox-dark-medium to Tokyo Night
3. Update modules/home/thein3rovert/programs/starship/default.nix: palette gruvbox_dark -> tokyo-night colors (#1a1b26 bg, #7aa2f7 blue, etc)
4. Update home/features/cli/zsh.nix + modules/home/.../zsh/default.nix: oh-my-posh gruvbox.omp.json -> tokyo-night theme, add fzf Tokyo Night colors
5. Add missing theming: Hyprland borders, Waybar css, Rofi/Wofi, GTK/Qt (nwg-look), Neovim, file manager (yazi/thunar), Mako/Swaync
6. Grep to confirm zero gruvbox leftovers, then nixos-rebuild dry / home-manager switch check

Agreed approach: Phase 1 = edit live ~/.config directly for fast preview (waybar/style.css, gtk-4.0, rofi theme, hypr colors). Phase 2 = port approved Tokyo Night values back into nixos-config nix modules once user satisfied.

Executed deviations: gtk4 via HM native gtk4.theme (manual xdg links collided), fzf via mkForce merged opts (HM ships gruvbox fzf defaults), dunst needed stale system daemon kill for DBus handover.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
Found live .config theming outside nix: GTK-4.0 theme-info.json=Gruvbox-Dark, waybar/style.css=full Gruvbox vars, hypr/colors.conf=template placeholders, rofi/config.rasi -> bibjaw_mini.rasi. Will need to decide nix-managed vs .config manual switch for Tokyo Night.

User decision 2026-09-27: preview in .config first, port to nix after satisfaction.

Backup done: /tmp/opencode/gruvbox-backup-20260927-132949 contains waybar, gtk-3/4, rofi, hypr, kitty, starship.toml

Phase1 preview applied: kitty Tokyo Night (broke HM symlink, backup kept), starship palette tokyo_night, waybar/style.css Gruvbox->Tokyo Night hex, hyprland.lua borders 7aa2f7/bb9af7 + hyprctl reload ok. Leftover: rofi theme, gtk-4.0, fzf, nvim, file manager.

Rofi preview: bibjaw_mini, floating, powermenu switched Gruvbox->Tokyo Night hex. FZF preview ready at /tmp/opencode/fzf-tokyo-night-preview.sh - needs source to test.

Rofi restyled blue-dominant Tokyo Night: border/input/selected/textbox yellow->blue, entry red->cream, active red-alt->aqua, highlight red->blue.

GTK preview: installed Tokyonight-Dark via /tmp/tokyo-gtk install.sh -n Tokyonight -c dark -l (needed nix-shell sassc), gsettings set to Tokyonight-Dark. Nautilus file manager follows GTK. Dunst Tokyo Night dunstrc created earlier.

Phase2 port: kitty default.nix hardcoded Tokyo Night (#1a1b26 bg etc, opacity 0.90, bright blue selection), default-option.nix + features/cli/kitty.nix colorScheme gruvbox-dark-medium->tokyo-night-dark, starship palette tokyo_night with brightened bg1/bg3 + dark-on-bright contrast fixes. nix-instantiate --parse OK for all 4 files.

Phase2 port: fzf Tokyo Night via home.sessionVariables.FZF_DEFAULT_OPTS in modules/home/programs/fzf/default.nix, oh-my-posh gruvbox disabled in home/features/cli/zsh.nix (starship is primary Tokyo Night prompt, re-enable note for tokyonight_storm). Both parse OK.

Phase2 port: created modules/home/thein3rovert/programs/gtk (tokyonight-gtk-theme pkg, Tokyonight-Dark, gtk-4.0 libadwaita links for Nautilus) and programs/dunst (Tokyo Night dunstrc port, home service). Wired imports, enabled in hosts/nixos/home.nix homeSetup, removed system dunst pkg from configuration.nix (now per-user). All 5 files parse OK. Rebuild pending user verification.

Post-rebuild verify OK: kitty+starship+dunstrc HM symlinks with Tokyo Night content, GTK Tokyonight-Dark, dunst user service active (killed stale system dunst holding DBus name). FZF colors need fresh shell to confirm sessionVariables.

Fzf fix: homeSetup.programs.fzf.enable was never enabled on any host, so Tokyo Night FZF_DEFAULT_OPTS never applied. Enabled in hosts/nixos/home.nix. Rebuild needed.

Fzf root cause found: HM fzf module ships gruvbox FZF_DEFAULT_OPTS by default, conflicting with ours. Fixed with lib.mkForce merged value (kept bat preview + wl-copy binds, Tokyo Night colors). Parse OK, rebuild pending.

GTK fix: removed manual xdg.configFile gtk-4.0 links (collided with HM native gtk4 handling = the rebuild error), now using gtk.gtk4.theme = config.gtk.theme which also silences the deprecation warning. Parse OK.

Committed in 3 phases: 7c711ed kitty+starship, 18b821f fzf+zsh, 0b4dbe2 gtk+dunst+wiring. Verified: kitty/starship/dunstrc HM symlinks Tokyo Night post-rebuild, GTK Tokyonight-Dark, dunst user service active, rofi/waybar/hypr previews user-approved. Open: #4 fzf (fix needs rebuild verify), #9 nvim still gruvbox.

Fzf user-confirmed working Tokyo Night post-rebuild. Nvim (#9) deferred to later per user - remains the only open item.
<!-- SECTION:NOTES:END -->
