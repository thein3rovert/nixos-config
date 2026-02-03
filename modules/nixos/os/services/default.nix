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
    ./memos
    ./traefikk
    ./adguard
    ./test
    ./minio
    ./postgres
    ./myslql
    ./n8n
    ./garage
    ./fossflow
    # lxc
    ./garage-webui
    ./ad-guard
    ./zerobyte
    ./dockhand
    ./hawser
  ];
}
