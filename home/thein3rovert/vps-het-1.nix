{ config, ... }:
{
  imports = [
    ./cloud-server.nix # INFO: Replace for home.nix
    # ../features/cli # TODO: Add later
    ../common
  ];
}
