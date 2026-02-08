{ lib, config, ... }:
let
  inherit (lib)
    mkOption
    types
    ;

  cfg = config.homelab;
in
{
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
    runtime = "podman";
    network = "homelab";
    storageDriver = "overlay2";
  };
}
