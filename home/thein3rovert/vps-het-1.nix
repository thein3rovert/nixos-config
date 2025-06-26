# WARNING: This file belog to the vps-het-1 server and is currently not in use
# it is now managed by the module config
{ config, ... }:
{
  imports = [
    ./cloud-server.nix # INFO: Replace for home.nix
    # ../features/cli # TODO: Add later
    ../common
  ];
}
