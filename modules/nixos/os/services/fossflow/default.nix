{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.nixosSetup.programs.fossflow;
in
{
  options.nixosSetup.programs.fossflow.enable = lib.mkEnableOption "Infrastruture Diagram tools";

  config = lib.mkIf cfg.enable {

    virtualisation.oci-containers.containers.fossflow = {
      image = "stnsmith/fossflow:latest";
      ports = [ "8087:80" ];

      # TODO: ADD PATH UNDER NETWORKING BASE MODULES
      volumes = [ "/var/lib/fossflow/diagrams:/data/diagrams" ];

      environment = {
        ENABLE_SERVER_STORAGE = "true"; # Uncomment to disable
      };
    };
    # Optionally ensure directory exists
    systemd.tmpfiles.rules = [
      "d /var/lib/fossflow/diagrams 0755 root root -"
    ];
  };
}
