{ lib, ... }:
{
  imports = [
    # ./minio
    ./linkding
    ./tailscale
    ./audiobookshelf
    ./nginx
    ./traefik

    # Monitoring
    ./glance
    ./uptime-kuma
    ./grafana

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
    ./forgejo
  ];
}
