{
  pkgs,
  config,
  lib,
  ...
}:

{
  programs.firefox.enable = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = [ ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.zsh.enable = true;

}
