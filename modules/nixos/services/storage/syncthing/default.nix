{
  config,
  lib,
  ...
}: {
  options.nixosSetup.services.syncthing = {
    enable = lib.mkEnableOption "Syncthing file syncing service.";

    certFile = lib.mkOption {
      description = "Path to the certificate file.";
      type = lib.types.path;
    };

    keyFile = lib.mkOption {
      description = "Path to the key file.";
      type = lib.types.path;
    };

    user = lib.mkOption {
      description = "User to run Syncthing as.";
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.nixosSetup.services.syncthing.enable {
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    services.syncthing = let
      cfg = config.nixosSetup.services.syncthing;
    in {
      enable = true;
      cert = cfg.certFile;
      configDir = "${config.services.syncthing.dataDir}/.syncthing";
      dataDir = "/home/${cfg.user}";
      key = cfg.keyFile;
      openDefaultPorts = true;
      inherit (cfg) user;

      settings = {
        options = {
          localAnnounceEnabled = true;
          relaysEnabled = true;
          urAccepted = -1;
        };
      };
    };
  };
}
