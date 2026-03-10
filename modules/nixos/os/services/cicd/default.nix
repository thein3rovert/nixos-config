{ lib, ... }:
{
  imports = [
    ./forgejo
    ./forgejo-runner
    ./rancher
    ./vault
  ];
}
