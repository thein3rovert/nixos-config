{ config, lib, ... }:
let
  /*
    TODO: Before delete of this test, make sure
    # we have a module that accomodate:
    # - Local and Public Domain
    # - TCP and HTTPS,as we have local and public services
    # - Difference certificate resolver
  */
  if-linkding-enable = lib.mkIf config.nixosSetup.services.linkdingTest.enable;
in
{
  # Change port from 9090 to something else so s3 can make use of it
  options.nixosSetup.services.linkdingTest = {
    enable = lib.mkEnableOption "Linkding Bookmarker Service";
  };

  config = if-linkding-enable {

    virtualisation.oci-containers.containers."linkding" = {
      image = "sissbruecker/linkding:latest";
      ports = [ "10.20.0.1:9090:9090" ]; # Local port mapping
      volumes = [ "linkding_data:/etc/linkding/data" ]; # Persistent storage
      environment = {
        LD_DISABLE_BACKGROUND_TASKS = "true";
      };
      environmentFiles = [ config.age.secrets.linkding.path ];
    };
  };
}
