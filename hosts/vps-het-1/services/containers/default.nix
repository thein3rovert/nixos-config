{ lib, ... }:
{
  imports = [
    ./slash.nix
    # ./pgadmin.nix
    ./linkding.nix
    ./freshrss.nix
    ./glance.nix
  ];

  # Web network for podman has been created belowscript not needed after
  # system.activationScripts.createPodmanNetworkWeb = lib.mkAfter ''
  #       if ! /run/current-system/sw/bin/podman network exists web; then
  #     /run/current-system/sw/bin/podman network create web --subnet=10.89.0.0/24 --internal
  #   fi
  # '';

}
