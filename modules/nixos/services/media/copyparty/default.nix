{
  config,
  lib,
  pkgs,
  ...
}:
let

  if-copyparty-enable = lib.mkIf config.nixosSetup.services.copyparty.enable;
  imageName = "docker.io/copyparty/ac";
  imageTag = "latest";
  port = config.homelab.ipRegistry.copyparty.port;

  # Mount volumes
  dataVolume = "/mnt/storage/copyparty:/w";
  configVolume = "/var/lib/copyparty/config:/cfg";

  configFile = pkgs.writeText "copyparty.conf" ''
    [global]
    hist: /cfg/hists/

    [/shared]
      /w
      accs:
        rw: *
  '';
in
{
  options.nixosSetup.services.copyparty = {
    enable = lib.mkEnableOption "copyparty file sharing server";
  };

  config = if-copyparty-enable {
    # Create required directories
    systemd.tmpfiles.rules = [
      "d /mnt/storage/copyparty 0755 1000 1000 -"
      "d /var/lib/copyparty/config 0755 1000 1000 -"
    ];

    # Copy config file before container starts
    systemd.services.podman-copyparty = {
      preStart = ''
        rm -f /var/lib/copyparty/config/copyparty.conf
        cp ${configFile} /var/lib/copyparty/config/copyparty.conf
        chown 1000:1000 /var/lib/copyparty/config/copyparty.conf
      '';
    };

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
