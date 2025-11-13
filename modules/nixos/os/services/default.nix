{ lib, ... }:
{
  imports = [
    # ./minio
    ./linkding
    ./tailscale
    ./audiobookshelf
    ./nginx
    ./traefik
    ./glance
    ./uptime-kuma
    ./jotty
    ./traefikk
    ./adguard
    ./test

    ./postgres
    ./myslql
  ];
  system.activationScripts.createPodmanNetworkWeb = lib.mkAfter ''
    if ! /run/current-system/sw/bin/podman network exists web; then
      /run/current-system/sw/bin/podman network create web --subnet=10.89.0.0/24 --internal 
    fi 
  '';
}
