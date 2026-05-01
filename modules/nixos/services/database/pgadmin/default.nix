{
  pkgs,
  lib,
  config,
  ...
}:
let
  if-pgadmin-enable = lib.mkIf config.nixosSetup.services.pgadmin.enable;
in
{
  options.nixosSetup.services.pgadmin = {
    enable = lib.mkEnableOption "pgAdmin - PostgreSQL management tool";

    email = lib.mkOption {
      type = lib.types.str;
      default = "admin@localhost";
      description = "Initial email for pgAdmin account";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = pkgs.writeText "thein3rovert-1234" "admin";
      description = "Path to file containing initial password (min 6 chars)";
    };
  };

  config = if-pgadmin-enable {
    services.pgadmin = {
      enable = true;
      port = config.homelab.containerPorts.pgadmin;
      openFirewall = true;
      initialEmail = config.nixosSetup.services.pgadmin.email;
      initialPasswordFile = config.nixosSetup.services.pgadmin.passwordFile;
    };
  };
}
