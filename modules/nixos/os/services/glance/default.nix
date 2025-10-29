{
  config,
  lib,
  ...
}:
let

  if-glance-enable = lib.mkIf config.nixosSetup.services.linkding.enable;
  imageName = "glanceapp/glance";
  host = "127.0.0.1";
  port = 8280;

  glanceConfig = "/home/thein3rovert/.config/glance/config";
  glanceTimeZone = "/etc/timezone";
  glanceLocalTime = "/etc/localtime";
  glanceAssets = "/home/thein3rovert/.config/glance/config/assets";
in
{
  options.nixosSetup.services.glance = {
    enable = lib.mkEnableOption "Glance Dashboard";
  };

  config = if-glance-enable {
    myContainers.traefik = {
      enable = true;
      defaultEntryPoints = [ "websecure" ];
      defaultCertResolver = "godaddy";
    };
    myContainers = {
      enable = true;
      containers = {
        glance = {
          image = "${imageName}";
          ports = [ "${host}:${toString port}:8080" ];
          volumes = [
            "${glanceConfig}:/app/config"
            "${glanceLocalTime}:/etc/localtime:ro"
            "${glanceTimeZone}:/etc/timezone:ro"
            "${glanceAssets}:/app/assets"
          ];
          environment = {
            LD_DISABLE_BACKGROUND_TASKS = "true";
          };
          traefik = {
            enable = true;
            url = "http://localhost:8280/";
            rule = "Host(`glance.thein3rovert.dev`)";
          };

        };
      };
    };
  };
}
