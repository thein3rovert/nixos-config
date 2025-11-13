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
    systemd.services.n8n.serviceConfig = {
      EnvironmentFile = [ "${config.age.secrets.n8n.path}" ];
    };
  };

}
