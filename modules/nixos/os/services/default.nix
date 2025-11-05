{ ... }:
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
  ];
}
