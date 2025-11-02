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

  # Use lib.path.append to safely handle relative paths
  glanceSrc = lib.path.append ./. "glance";

  glanceSrc3 = lib.path.append ./. "glance";

  glanceSrc2 = builtins.toPath ./glance/.;
  glanceSecret = config.age.secrets.linkding2.path;
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
    # system-wide glance config files
    # environment.etc."glance".source = "${glanceSrc}/config.yml";
    # environment.etc."glance/assets/penguin.png".source = "${glanceSrc}/assets/penguin.png";
    # environment.etc."glance/.env".source = glanceSecret;
    # environment.etc."glance2".source = glanceSrc2;

    environment.etc = {
      "glance/config.yml".source = "${glanceSrc}/glance.yml";
      "glance/.env".source = glanceSecret;
      "glance/assets/penguin.png".source = "${glanceSrc}/assets/penguin.png";
    };

    # Another way
    # environment.etc."glance-env".target = "glance/.env2";
    # environment.etc."glance-env".source = glanceSecret;

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
            BASE_DOMAIN = "thein3rovert.dev";
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
