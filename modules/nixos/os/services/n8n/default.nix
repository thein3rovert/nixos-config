{
  pkgs,
  lib,
  config,
  ...
}:
let
  if-n8n-enable = lib.mkIf config.nixosSetup.services.n8n.enable;
in
{

  options.nixosSetup.services.n8n = {
    enable = lib.mkEnableOption "Automation";
  };
  config = if-n8n-enable {
    services.n8n = {
      enable = true;
      openFirewall = true;
    };

    systemd.services.n8n = {
      enable = true;

      # Ensure the service has the correct PATH to find node and n8n
      environment = {
        N8N_RUNNERS_MODE = "internal";
        N8N_RUNNERS_CHILD_PROCESS = "true";
        # Force PATH so it overrides the default
        PATH = lib.mkForce "${pkgs.nodejs}/bin:${pkgs.n8n}/bin:/run/wrappers/bin:/usr/bin";
      };

      # Keep existing EnvironmentFile if needed
      serviceConfig = {
        EnvironmentFile = [ "${config.age.secrets.n8n.path}" ];
      };
    };
  };

}
