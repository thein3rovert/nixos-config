{ pkgs, ... }:
{
  imports = [

  ];
  home.packages = with pkgs; [
    obsidian
    # Waybar with experimental features enabled
    # (waybar.overrideAttrs (oldAttrs: {
    #   mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
    # }))
    rofi
    gnome-tweaks
    wasistlos
    spotify
    obs-studio
    wpsoffice
    textsnatcher
    hyprcursor
    hyprshot
    zathura
    banana-cursor
    nwg-look
    discord
    sticky-notes
    todoist-electron
  ];
}
