{ config, pkgs, ... }:
{
  imports = [
    # ./docker.nix
  ];

  environment.systemPackages = with pkgs; [
    docker-compose
  ];
}
