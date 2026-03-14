{
  config,
  lib,
  ...
}:
let

  if-copyparty-enable = lib.mkIf config.nixosSetup.services.copyparty.enable;
  imageName = "docker.io/copyparty/ac";
  imageTag = "latest";
  port = config.homelab.ipRegistry.copyparty.port;

  # Mount volumes
  dataVolume = "/mnt/storage/copyparty:/w";
  configVolume = "/etc/copyparty:/cfg";
in
{
  options.nixosSetup.services.copyparty = {
    enable = lib.mkEnableOption "copyparty file sharing server";
  };

  config = if-copyparty-enable {
    # Create required directories
    systemd.tmpfiles.rules = [
      "d /mnt/storage/copyparty 0755 1000 1000 -"
      "d /etc/copyparty 0755 1000 1000 -"
    ];

    virtualisation.oci-containers.containers.copyparty = {
      image = "${imageName}:${imageTag}";
      ports = [ "${toString port}:3923" ];
      volumes = [
        dataVolume
        configVolume
      ];
      user = "1000:1000";
      extraOptions = [
        "--label=io.containers.autoupdate=registry"
      ];
    };
  };
}
