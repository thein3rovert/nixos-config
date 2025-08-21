{
  pkgs,
  config,
  lib,
  ...
}:

{
  programs.firefox.enable = true;

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.zsh.enable = true;

  # INFO: Handling now with modules

  # Nix language Server
  # programs.nix-ld.enable = true;
  # programs.nix-ld.libraries = [ ];

  # OBS Configuration
  # programs.obs-studio = {
  #   enable = true;
  #   enableVirtualCamera = true;
  #   plugins = with pkgs.obs-studio-plugins; [
  #     obs-composite-blur # blur effects for scenes
  #     obs-vaapi # VAAPI hardware encoding
  #     obs-vertical-canvas # vertical video layout support
  #     obs-vkcapture # capture Vulkan applications
  #     obs-webkitgtk # web sources via WebKitGTK
  #     wlrobs # screen capture for Waylandgtk
  #     wlrobs
  #   ];
  # };

}
