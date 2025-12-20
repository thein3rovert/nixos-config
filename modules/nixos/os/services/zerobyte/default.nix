{
  config,
  lib,
  ...
}:
let
  if-zerobyte-enable = lib.mkIf config.nixosSetup.services.zerobyte.enable;
  homelab = config.homelab;

  imageName = "ghcr.io/nicotsx/zerobyte";
  imageTag = "v0.19";
  host = "0.0.0.0";
  port = homelab.containerPorts.zerobyte or 4096;
  dataPath = homelab.containerStorage.zerobyte.path or "/var/lib/zerobyte";
in
{
  options.nixosSetup.services.zerobyte = {
    enable = lib.mkEnableOption "ZeroByte backup automation";
  };

  config = if-zerobyte-enable {
    # Create data directory
    systemd.tmpfiles.rules = [
      "d ${dataPath} 0755 ${homelab.baseUser} ${homelab.baseGroup} -"
    ];

    myContainers = {
      enable = true;
      containers = {
        zerobyte = {
          image = "${imageName}:${imageTag}";
          ports = [ "${host}:${toString port}:4096" ];
          volumes = [
            "/etc/localtime:/etc/localtime:ro"
            "${dataPath}:/var/lib/zerobyte"
            # Optional: mount local directories
            # "/path/to/your/directory:/mydata"
          ];
          environment = {
            TZ = homelab.timeZone or "Europe/Paris";
          };
          extraOptions = [
            "--cap-add=SYS_ADMIN"
            "--device=/dev/fuse:/dev/fuse"
          ];
        };
      };
    };
  };
}
