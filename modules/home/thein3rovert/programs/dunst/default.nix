{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.dunst.enable =
    lib.mkEnableOption "Tokyo Night Dunst notifications for main user thein3rovert";

  config = lib.mkIf config.homeSetup.thein3rovert.programs.dunst.enable {
    services.dunst = {
      enable = true;
      settings = {
        # Tokyo Night - ported from .config preview
        global = {
          font = "JetBrainsMono Nerd Font 10";
          frame_color = "#7aa2f7";
          separator_color = "#292e42";
          corner_radius = 10;
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        urgency_low = {
          background = "#1a1b26";
          foreground = "#a9b1d6";
          frame_color = "#565f89";
          timeout = 5;
        };
        urgency_normal = {
          background = "#1a1b26";
          foreground = "#c0caf5";
          frame_color = "#7aa2f7";
          timeout = 5;
        };
        urgency_critical = {
          background = "#1a1b26";
          foreground = "#f7768e";
          frame_color = "#f7768e";
          timeout = 0;
        };
      };
    };
  };
}
