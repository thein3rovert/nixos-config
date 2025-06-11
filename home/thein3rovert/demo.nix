{ config, ... }:
{
  imports = [
    ./nixlab-vm1.nix # INFO: Replace for home.nix
    #../features/cli # TODO: Add later
    ../common
  ];
}
