#INFO: This is a test for remote reployment with colema
# This is a replica for home.nix for the demo server
# WARNING: This file belog to the demo server and is currently not in use
# it is now managed by the module config
{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = lib.mkDefault "thein3rovert";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    cowsay
    xclip

  ];

  home.file = {
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM = 1;
  };

  programs.home-manager.enable = true;
}
