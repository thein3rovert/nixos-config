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

    ./n8n
  ];
}
