{ config, pkgs, ... }:
{
  imports = [
    ./docker.nix
  ];

    environment.systemPackages = with pkgs; [
    lazydocker
    docker-compose
  ];
}
