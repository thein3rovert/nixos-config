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
    #
    # systemd.services.n8n = {
    #   environment = {
    #     N8N_SECURE_COOKIE = "false";
    #     N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS = "false";
    #     DB_TYPE = "postgresql";
    #
    #     DB_POSTGRESDB_HOST = "n8n";
    #     DB_POSTGRESDB_DATABASE = "n8n";
    #     DB_POSTGRESDB_USER = "n8n";
    #     DB_POSTGRESDB_PASSWORD = "n8n";
    #     N8N_BASIC_AUTH_ACTIVE = "true";
    #     N8N_BASIC_AUTH_USER = "n8n";
    #     N8N_BASIC_AUTH_PASSWORD = "n8n_pass";
    #
    #     # Addtional
    #     N8N_RUNNERS_ENABLED = " false";
    #   };
    # };
  };

}
