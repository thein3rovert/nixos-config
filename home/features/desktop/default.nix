{ pkgs, ... }:
{
  imports = [

  ];
  home.packages = with pkgs; [
    obsidian
    # Waybar with experimental features enabled
    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    }))
    rofi
    gnome-tweaks
    wasistlos
    spotify
    obs-studio
    wpsoffice
    sticky-notes
    textsnatcher
    hyprcursor
    hyprshot
    zathura
    anytype
    banana-cursor
    nwg-look
  ];
}
