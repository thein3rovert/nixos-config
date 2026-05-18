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

    settings = lib.mkOption {
      default = {};
      description = "Additional Syncthing settings (devices, folders, etc.)";
      type = lib.types.attrs;
    };
  };

  config = lib.mkIf config.nixosSetup.services.syncthing.enable {
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";

    networking.firewall.allowedTCPPorts = [ 8384 ];

    services.syncthing = let
      cfg = config.nixosSetup.services.syncthing;
    in {
      enable = true;
      cert = cfg.certFile;
      configDir = "${config.services.syncthing.dataDir}/.syncthing";
      dataDir = "/home/${cfg.user}";
      key = cfg.keyFile;
      openDefaultPorts = true;
      guiAddress = "0.0.0.0:8384";
      inherit (cfg) user;

      settings = lib.mkMerge [
        {
          options = {
            localAnnounceEnabled = true;
            relaysEnabled = true;
            urAccepted = -1;
          };
        }
        cfg.settings
      ];
    };
  };
}
