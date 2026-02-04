{ lib, config, ... }:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkIf
    mkForce
    ;

  cfg = config.homelab.services;
in
{
  options.homelab.services = {
    enable = mkEnableOption "Master switch for all homelab services";

    description = mkOption {
      type = lib.types.str;
      default = "Controls whether service modules can be activated";
      description = ''
        When disabled, all service modules will be forcibly disabled regardless 
        of their individual enable settings in host configurations.
        This provides a base layer control for all services.
      '';
    };
  };

  config = mkIf (!cfg.enable) {
    # When homelab.services.enable is false, forcibly disable all services
    # This overrides any host-level service enablement
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
