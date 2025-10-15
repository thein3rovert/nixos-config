{ lib, config, ... }:
let
  if-freshrss-enabled = lib.mkIf config.nixosSetup.containers.freshrss.enable;
in
{
  # imports = [ ./base.nix ];
  options.nixosSetup.containers.freshrss = {
    enable = lib.mkEnableOption "Enable Freshrss Services";
  };
  config = if-freshrss-enabled {
    myContainers = {
      enable = true;
      containers = {
        freshrss = {
          image = "freshrss/freshrss:latest";
          ports = [ "127.0.0.1:8083:80" ];
          volumes = [
            "freshrss_data:/etc/freshrss/data"
            "freshrss_data:/var/www/FreshRSS/data"
            "freshrss_extensions:/var/www/FreshRSS/extensions"
          ];
          environment = {
            TZ = "Europe/London";
            CRON_MIN = "2,32";
            FRESHRSS_ENV = "development";
            OIDC_ENABLED = "0";
          };
          environmentFiles = [ config.age.secrets.freshrss.path ];
        };
      };
    };
  };
}
