{
  config,
  lib,
  ...
}:
let
  cfg = config.nixosSetup.services.rancher;
in
{
  options.nixosSetup.services.rancher.enable = lib.mkEnableOption "Kubernetes Management tool";
  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.rancher = {
      image = "rancher/rancher:latest";
      ports = [
        "9080:80"
        "9443:443"
      ];
      volumes = [
        "/var/lib/rancher:/var/lib/rancher"
      ];
      extraOptions = [ "--privileged" ];
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/rancher 0755 root root -"
    ];
  };
}
