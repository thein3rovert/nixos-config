{
  pkgs,
  lib,
  config,
  ...
}:
let
  if-podman-network-enable = lib.mkIf config.nixosSetup.programs.podman-network.enable;
in
{
  options.nixosSetup.programs.podman-network = {
    enable = lib.mkEnableOption "Create Podman web network";
  };
  config = if-podman-network-enable {
    system.activationScripts.createPodmanNetworkWeb = lib.mkAfter ''
      if ! /run/current-system/sw/bin/podman network exists web; then
        /run/current-system/sw/bin/podman network create web --subnet=10.89.0.0/24 --internal 
      fi 
    '';
  };
}
