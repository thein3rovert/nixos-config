{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.homelab;
in
{
  imports = [
    ./base.nix
    ./traefik.nix
  ];

  # ============================================
  # Container Options
  # ============================================
  options.homelab.containers = {
    runtime = mkOption {
      type = types.enum [
        "podman"
        "docker"
      ];
      default = "podman";
      description = "Container runtime to use";
    };

    network = mkOption {
      type = types.str;
      default = "homelab";
      description = "Default container network name";
    };

    storageDriver = mkOption {
      type = types.str;
      default = "overlay2";
      description = "Container storage driver";
    };
  };

  # ============================================
  # Container Configuration
  # ============================================
  config.homelab.containers = {
    runtime = lib.mkDefault (
      if config.nixosSetup.programs.podman.enable or false then
        "podman"
      else if config.nixosSetup.programs.docker.enable or false then
        "docker"
      else
        "podman" # fallback default
    );
    network = "homelab";
    storageDriver = "overlay2";
  };
}
