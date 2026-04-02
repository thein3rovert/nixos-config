{
  config,
  lib,
  ...
}:
let

  if-fileshare-enable = lib.mkIf config.nixosSetup.services.fileshare.enable;
  # create-linkding-containter = virtualisation.oci-containers."linkding";
  imageName = "gtstef/filebrowser:${imageTag}";
  imageTag = "stable";
  port = 8900;

  # FileBrowser volumes
  dataVolume = "/var/lib/filebrowser/data:/home/filebrowser/data";
  filesVolume = "/var/lib/filebrowser/files:/files";
  config-file = "/etc/filebrowser/config.yaml:/home/filebrowser/data/config.yaml:ro";
in
{
  options.nixosSetup.services.fileshare = {
    enable = lib.mkEnableOption "File sharing Service";
  };

  config = if-fileshare-enable {
    # Create data directory and config file
    systemd.tmpfiles.rules = [
      "d /var/lib/filebrowser/data 0755 root root -"
      "d /var/lib/filebrowser/data/tmp 0755 root root -"
      "d /var/lib/filebrowser/files 0755 root root -"
    ];

    environment.etc."filebrowser/config.yaml".text = ''
      server:
        database: "data/database.db"
        cacheDir: "data/tmp"
        sources:
          - path: "/files"
            name: Home
            config:
              defaultUserScope: "/"
              defaultEnabled: true
              createUserDir: false
        maxArchiveSize: 50
      auth:
        tokenExpirationHours: 2
        methods:
          password:
            enabled: true
            minLength: 5
            signup: false
        adminUsername: thein3rovert
        adminPassword: filebrowser123
    '';

    virtualisation.oci-containers.containers.fileshare = {
      image = "${imageName}";
      ports = [ "${toString port}:80" ];
      volumes = [
        dataVolume
        filesVolume
        config-file
      ];
      environment = {
        FILEBROWSER_CONFIG = "data/config.yaml";
      };
    };
  };

}
