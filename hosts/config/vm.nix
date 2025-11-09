{ config, pkgs, ... }:

{
  # Helps in low-level configuration system used by gnome and other desktop eenvironment
  programs.dconf.enable = true;

  # Added libvirtd to the user group to allow management of virtual machines
  users.users.thein3rovert.extraGroups = [ "libvirtd" ];

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

  # Configure vvirtualisation services and features
  virtualisation = {
    libvirtd = {
      enable = true; # Main virtualisation daemon (KVM/QEMU Management)
      qemu = {
        # Enable software TPM for vms ( window 11 and secure boot)
        swtpm.enable = true;
        # Allow UEFI boot by enable UEFI firmware
        #   ovmf.enable = true;
        #  ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    # Allow for passing USB devices from host to the virtual machines
    spiceUSBRedirection.enable = true;
  };

  # Enable the SPICE vdagent daemon, improving clipboard, display resizing, and other integration
  # features between host and (mostly Linux) guest VMs.
  services.spice-vdagentd.enable = true;
}
