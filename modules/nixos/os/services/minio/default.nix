{
  config,
  lib,
  ...
}:
{
  # Define options schema - mkEnableOption creates a boolean option with default false
  # wrapping in inside enable it better
  options.nixosSetup.services.minio = {
    enable = lib.mkEnableOption "S3 services";
  };
  config = lib.mkIf config.nixosSetup.services.minio.enable {

    virtualisation.oci-containers.containers."minio" = {
      image = "minio/minio";
      ports = [
        # "127.0.0.1:9000:9000" # MinIO API Port
        # "127.0.0.1:9090:9090" # MinIO Console Port
        "0.0.0.0:9000:9000"
        "0.0.0.0:9090:9090"
      ];
      volumes = [ "minio_data:/etc/minio/data" ]; # Persistent storage
      environment = {
        MINIO_ROOT_USER = "admin";
        MINIO_ROOT_PASSWORD = "mysecretpassword";
      };

      cmd = [
        "server"
        "--console-address"
        ":9090"
        "/etc/minio/data"
      ];
      # environmentFiles = [ config.age.secrets.linkding.path ];
    };
  };
}
