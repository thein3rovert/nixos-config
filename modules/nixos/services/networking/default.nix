{ lib, ... }:
{
  imports = [
    ./tailscale
    ./nginx
    ./traefik
    ./traefikk
    ./adguard
    ./ad-guard
  ];
}
