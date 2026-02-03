{
  config,
  lib,
  ...
}:
let
  imageName = "neosmemo/memos";
  imageTag = "stable";
  port = 5230;
  dataVolume = "/var/lib/memos:/var/opt/memos";
  cfg = config.nixosSetup.services.memos;
in
{
  options.nixosSetup.services.memos.enable = lib.mkEnableOption "Notes and Idea taking tool";

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.containers.memos = {
      image = "${imageName}:${imageTag}";
      ports = [ "${toString port}:5230" ];

      # TODO: ADD PATH UNDER NETWORKING BASE MODULES
      volumes = [ dataVolume ];
    };
    systemd.tmpfiles.rules = [
      "d /var/lib/memos 0755 root root -"
    ];
  };
}
