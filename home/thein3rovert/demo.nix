# WARNING: This file belog to the demo server and is currently not in use
# it is now managed by the module config
{ config, ... }:
{
  imports = [
    ./nixlab-vm1.nix # INFO: Replace for home.nix
    # ../features/cli # TODO: Add later
    ../common
  ];
}
