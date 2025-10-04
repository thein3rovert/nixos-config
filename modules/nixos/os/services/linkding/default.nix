{
  config,
  lib,
  ...
}:
let

  if-linkding-enable = lib.mkIf config.nixosSetup.services.linkding.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
in
{
  options.nixosSetup.services.linkding = {
    enable = lib.mkEnableOption "Linkding Bookmarker Service";
  };

  config = if-linkding-enable {
    # Create a base config for virtulvirtualisation
    virtualisation.oci-containers.containers."linkding" = {
      image = "sissbruecker/linkding:latest";
      ports = [ "127.0.0.1:9090:9090" ]; # Local port mapping
      volumes = [ "linkding_data:/etc/linkding/data" ]; # Persistent storage
      environment = {
        LD_DISABLE_BACKGROUND_TASKS = "true";
      };
      # Environment Files
      environmentFiles = [ config.age.secrets.linkding.path ];
    };
  };
}
