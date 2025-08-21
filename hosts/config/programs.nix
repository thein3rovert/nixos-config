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

}
