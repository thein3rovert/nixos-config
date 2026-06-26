{
  pkgs,
  lib,
  config,
  ...
}:
let
  if-kaneo-enable = lib.mkIf config.nixosSetup.services.kaneo.enable;

  imageName = "ghcr.io/usekaneo/kaneo:${imageTag}";
  imageTag = "latest";
  port = config.homelab.containerPort.kaneo;

  dataVolume = "";

in
{

  options.nixosSetup.services.kaneo = {
    enable = lib.mkEnableOption " Project Management Software";
  };

  config = if-kaneo-enable {
    virtualisation.oci-containers.containers.kaneo = {
      image = "${imageName}";
      ports = [ "${toString port}:5173" ];
      volumes = [ ];
    };
  };
}
