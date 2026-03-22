{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Handled and managed by nixos services
  options.nixosSetup.programs.obs-studio.enable = lib.mkEnableOption "OBS Studio Configuration";

  config = lib.mkIf config.nixosSetup.programs.obs-studio.enable {
    programs.obs-studio = {
      enable = true;
      enableVirtualCamera = true;
      plugins = with pkgs.obs-studio-plugins; [
        obs-composite-blur # blur effects for scenes
        obs-vaapi # VAAPI hardware encoding
        #   obs-vertical-canvas # vertical video layout support
        obs-vkcapture # capture Vulkan applications
        # obs-webkitgtk # web sources via WebKitGTK
        wlrobs # screen capture for Waylandgtk
        wlrobs
      ];
    };
  };
}
