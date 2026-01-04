{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.apps.enable =
    lib.mkEnableOption "thein3rovert default desktop applications";

  config = lib.mkIf config.homeSetup.thein3rovert.programs.apps.enable {

    home.packages = with pkgs; [
      #====================
      # Desktop Utilities
      # ===================
      obs-studio
      obsidian
      pomodoro-gtk # Pomodoro timer with GTK interface
      zathura
      discord
      tauon
      vscode

      # TODO: Move to desktop -> hyprland when available
      swww # Wallpaper setter (move to desktop folder)
      rofi # Styling
      gnome-tweaks
      hyprcursor
      hyprshot
      banana-cursor
      nwg-look
    ];
  };
}
