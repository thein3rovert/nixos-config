{
  config,
  lib,
  pkgs,
  ...
}:
let

  cfg = config.nixosSetup.programs.virt-manager;
in
{
  options.nixosSetup.programs.virt-manager.enable = lib.mkEnableOption "Virtualisation Management";

  config = lib.mkIf cfg.enable {
    programs = {
      dconf.profiles.user.databases = lib.optionals config.services.xserver.enable [
        {
          # Automatically connect to system level
          # libvirt daemon on every start
          settings = {
            "org/virt-manager/virt-manager/connections" = {
              autoconnect = [ "qemu:///system" ];
              uris = [ "qemu:///system" ];
            };
          };
        }
      ];

      virt-manager.enable = lib.mkDefault config.services.xserver.enable;
    };

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          # Enable software TPM for vms ( window 11 and secure boot)
          swtpm.enable = true;
          # Allow UEFI boot by enable UEFI firmware
          # ovmf.enable = true;
          # ovmf.packages = [ pkgs.OVMFFull.fd ];
        };
      };
      # Allow for passing USB devices from host to the virtual machines
      spiceUSBRedirection.enable = true;
    };

    # Enable the SPICE vdagent daemon, improving clipboard, display resizing, and other integration
    # features between host and (mostly Linux) guest VMs.
    services.spice-vdagentd.enable = true;

    # Neccessary drivers for vm and windows
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      virtio-win
      win-spice
    ];

    users.users.thein3rovert.extraGroups = [ "libvirtd" ];
  };
}
