{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkForce
    types
    attrNames
    ;

  cfg = config.homelab.services;
  hostname = config.networking.hostName;

  # Get the host-specific service configuration
  hostServiceCfg = cfg.hosts.${hostname} or { enable = true; };
in
{
  options.homelab.services = {
    enable = mkEnableOption "Global master switch for all homelab services across all hosts";

    hosts = mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            enable = mkEnableOption "Enable services for this specific host";

            description = mkOption {
              type = types.str;
              default = "Host-specific service control";
              description = "Optional description for this host's service configuration";
            };
          };
        }
      );
      default = { };
      description = ''
        Per-host service control. Each hostname can have its own enable switch.
        Example:
          homelab.services.hosts.bellamy.enable = false;
          homelab.services.hosts.kira.enable = true;
      '';
    };
  };

  config = mkIf (!cfg.enable || !hostServiceCfg.enable) {
    # When either global services are disabled OR this specific host's services are disabled,
    # forcibly disable all services - this overrides any host-level service enablement
    nixosSetup.services = mkForce {
      # Explicitly disable all services by setting them to false
      traefik.enable = mkForce false;
      tailscale.enable = mkForce false;
      linkding.enable = mkForce false;
      glance.enable = mkForce false;
      uptime-kuma.enable = mkForce false;
      memos.enable = mkForce false;
      minio.enable = mkForce false;
      hawser.enable = mkForce false;
      garage-webui.enable = mkForce false;
      garage.enable = mkForce false;
      # Add any other services here as you create them
    };
  };
}
