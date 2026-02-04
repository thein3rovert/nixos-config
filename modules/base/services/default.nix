{ lib, config, ... }:
let
  inherit (lib)
    mkIf
    mkForce
    ;

  cfg = config.homelab.services;
  hostname = config.networking.hostName;

  # Get the host-specific service configuration
  # Default to enabled if host is not defined
  hostServiceCfg = cfg.hosts.${hostname} or { enable = true; };
in
{
  # Configuration logic only - options are declared in modules/base/default.nix
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
