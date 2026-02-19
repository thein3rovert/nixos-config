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
    ./promtail
    ./prometheusNode

    ./jotty
    ./memos
    ./traefikk
    ./adguard
    ./minio
    ./postgres
    ./myslql
    ./n8n
    ./garage
    ./fossflow
    ./blog
    # lxc
    ./garage-webui
    ./ad-guard
    ./zerobyte
    ./dockhand
    ./hawser
    ./forgejo
  ];
}
