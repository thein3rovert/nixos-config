{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.packages.desktop.enable =
    lib.mkEnableOption "thein3rovert desktop packages";

  config = lib.mkIf config.homeSetup.thein3rovert.packages.desktop.enable {

    home.packages = with pkgs; [
      # Desktop Utilities
      swww # Wallpaper setter (move to desktop folder)
      pomodoro-gtk # Pomodoro timer with GTK interface
      obsidian
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
  };
}
