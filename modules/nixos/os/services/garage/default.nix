{
  config,
  lib,
  ...
}:
{
  # Define options schema - mkEnableOption creates a boolean option with default false
  # wrapping in inside enable it better
  options.nixosSetup.services.garage = {
    enable = lib.mkEnableOption "S3 services";
  };
  config = lib.mkIf config.nixosSetup.services.garage.enable {
    services.garage = {
      enable = true;

      extraEnvironment = {
        RUST_BACKTRACE = "yes";
      };

      # TODO: Add age path
      environmentFile = [ ];

      logLevel = "info";

      settings = {
        # metadata_dir (Leave as default)
        # data_dir (Leave as default)
      };

    };
  };
}
