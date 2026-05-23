{
  config,
  lib,
  ...
}:
let
  if-say-cheese-enable = lib.mkIf config.nixosSetup.services.say-cheese.enable;
  imageName = "theintrovert/say-cheese";
  imageTag = "latest";
  port = config.homelab.containerPorts.say-cheese;
in
{
  options.nixosSetup.services.say-cheese = {
    enable = lib.mkEnableOption "Say Cheese - Photo Gallery App";
  };

  config = if-say-cheese-enable {
    systemd.tmpfiles.rules = [
      "d /home/thein3rovert/say-cheese-data 0755 thein3rovert users -"
    ];

    virtualisation.oci-containers.containers.say-cheese = {
      image = "${imageName}:${imageTag}";
      ports = [ "${toString port}:7070" ];
      volumes = [
        "/home/thein3rovert/say-cheese-data:/app/data"
      ];
    };
  };
}
