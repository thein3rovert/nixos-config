# ==============================
#      NFS Configuration
# ==============================
# This module configures NFS client/server configuration

{
  config,
  lib,
  ...
}:
{
  # ==============================
  #         Module Options
  # ==============================
  options.nixosSetup.profiles.nfs = {
    enable = lib.mkEnableOption "NFS client/server configuration";
    isServer = lib.mkEnableOption "NFS server (export shares)";
    isClient = lib.mkEnableOption "NFS client (mount remote shares)";

    exports = lib.mkOption {
      type = lib.types.lines;
      default = "";
      example = ''
        /backups 10.10.10.12(rw,sync,no_subtree_check)
      '';
      description = "NFS exports file contents (only used when isServer=true)";
      visible = "runtime";
    };

    mounts = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            mountPoint = lib.mkOption {
              type = lib.types.str;
              example = "/mnt/backups";
              description = "Local mount point for the NFS share";
            };
            device = lib.mkOption {
              type = lib.types.str;
              example = "100.105.187.63:/backups";
              description = "Remote NFS device path";
            };
            readOnly = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Mount as read-only";
            };
          };
        }
      );
      default = [ ];
      example = [
        {
          mountPoint = "/mnt/backups";
          device = "100.105.187.63:/backups";
          readOnly = false;
        }
      ];
      description = "List of NFS mounts to configure (only used when isClient=true)";
      visible = "runtime";
    };
  };

  # ==============================
  #     Backwards Compatibility
  # ==============================
  # If enable=true is set but neither isServer/isClient, enable both
  config.nixosSetup.profiles.nfs.isServer = lib.mkIf (
    config.nixosSetup.profiles.nfs.enable
    && !config.nixosSetup.profiles.nfs.isServer
    && !config.nixosSetup.profiles.nfs.isClient
  ) (lib.mkDefault true);
  config.nixosSetup.profiles.nfs.isClient = lib.mkIf (
    config.nixosSetup.profiles.nfs.enable
    && !config.nixosSetup.profiles.nfs.isServer
    && !config.nixosSetup.profiles.nfs.isClient
  ) (lib.mkDefault true);

  # ==============================
  #     NFS Client Configuration
  # ==============================
  config.services.nfs.settings = lib.mkIf config.nixosSetup.profiles.nfs.isClient { };
  config.services.rpcbind.enable = lib.mkIf config.nixosSetup.profiles.nfs.isClient true;

  config.fileSystems = lib.mkIf config.nixosSetup.profiles.nfs.isClient (
    lib.mkMerge (
      map (mount: {
        "${mount.mountPoint}" = {
          device = mount.device;
          fsType = "nfs";
          options = [
            "vers=4"
            "x-systemd.automount"
            "noauto"
          ]
          ++ lib.optionals mount.readOnly [ "ro" ];
        };
      }) config.nixosSetup.profiles.nfs.mounts
    )
  );

  # ==============================
  #     NFS Server Configuration
  # ==============================
  config.services.nfs.server = lib.mkIf config.nixosSetup.profiles.nfs.isServer {
    enable = true;
    exports = config.nixosSetup.profiles.nfs.exports;
  };
}
