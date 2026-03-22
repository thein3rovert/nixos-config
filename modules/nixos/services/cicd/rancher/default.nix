# Since i use podman, rancher dosnt work on podman
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
        "/sys/fs/cgroup:/sys/fs/cgroup:rw"
      ];
      extraOptions = [
        "--privileged"
        "--cgroupns=host"
        # Fixed issue with reset-flag (Remvoe reset flag)
        "--entrypoint=/var/lib/rancher/patched-entrypoint.sh"
      ];
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/rancher 0755 root root -"
    ];
  };
}
