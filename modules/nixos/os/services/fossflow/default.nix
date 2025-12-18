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
      volumes = [ "./diagrams:/data/diagrams" ];

      environment = {
        # ENABLE_SERVER_STORAGE = "false";  # Uncomment to disable
      };
    };
  };
}
