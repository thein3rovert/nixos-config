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
      #====================
      # Desktop Utilities
      # ===================

      # Applications
      obs-studio
      obsidian
      pomodoro-gtk # Pomodoro timer with GTK interface
      zathura
      discord
      tauon

      swww # Wallpaper setter (move to desktop folder)
      rofi # Styling
      gnome-tweaks
      hyprcursor
      hyprshot
      banana-cursor
      nwg-look

      # Optionals
      /*
        spotify
        wasistlos
        textsnatcher
      */

    ];
  };
}
