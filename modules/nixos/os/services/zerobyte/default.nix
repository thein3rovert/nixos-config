{
  config,
  lib,
  ...
}:
let
  if-zerobyte-enable = lib.mkIf config.nixosSetup.services.zerobyte.enable;
  cfg = config.nixosSetup.services.zerobyte;
  homelab = config.homelab;

  imageName = "ghcr.io/nicotsx/zerobyte";
  imageTag = "v0.19";
  host = "0.0.0.0";
  port = homelab.containerPorts.zerobyte or 4096;
  dataPath = homelab.containerStorage.zerobyte.path or "/var/lib/zerobyte";
  repository = "/var/lib/zerobyte/repositories";
in
{
  options.nixosSetup.services.zerobyte = {
    enable = lib.mkEnableOption "ZeroByte backup automation";

    extraVolumes = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "/home/thein3rovert/nixos-config:/nixos-config"
      ];
      description = "Additional volume mounts for local directories";
      example = [
        "/mnt/data:/data"
        "/home/user/documents:/documents:ro"
      ];
    };
  };

  config = if-zerobyte-enable {
    # Create data and repositories directories
    systemd.tmpfiles.rules = [
      "d ${dataPath} 0755 ${homelab.containerStorage.zerobyte.owner} ${homelab.containerStorage.zerobyte.group} -"
      "d ${dataPath}/repositories 0755 ${homelab.containerStorage.zerobyte.owner} ${homelab.containerStorage.zerobyte.group} -"
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
            # "${repository}:/var/lib/zerobyte/repositories"
          ] ++ cfg.extraVolumes;
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
