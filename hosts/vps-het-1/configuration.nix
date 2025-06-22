{
  modulesPath,
  lib,
  pkgs,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  users.groups.sudo = { };
  # boot.tmp.cleanOnBoot = true;
  # zramSwap.enable = true;
  networking.hostName = "vps-het-1";
  networking.domain = "";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.qemuGuest.enable = true;

  # Configure console keymap
  console.keyMap = "uk";

  environment.systemPackages = with pkgs; [
    git
    # vim
    # python3
    fastfetch
    micro
    tmux
    neovim
    # ------------------------------
    # CLI (Command Line Interface)
    # ------------------------------
    vim # Text editor
    # git # Version control tool
    # nh # Alternate to nix rebuild
    # nvd # Assist nh with colorful output
    # nix-output-monitor
    # nix-ld # Nix dynamic library management tool
    # nil
    # nixd
  ];
  users.users.thein3rovert-cloud = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "sudo"
    ];
    description = "thein3rovert-cloud-server";
    openssh.authorizedKeys.keys = [
      ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe''
    ];
  };

  # TODO: Be sure to remove this later
  environment.sessionVariables = {
    TERMINAL = "kitty"; # Since you prefer xterm over kitty
    NIX_LOG = "info";
  };
  # environment.sessionVariables = {
  #   XDG_RUNTIME_DIR = "/run/user/1000";
  #   DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
  # };
  # boot.kernelPackages = pkgs.linuxPackages_6_6;
  #boot.isContainer = true;

  # Allowing nix flake to work
  users.users.root.openssh.authorizedKeys.keys = [
    ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGKcMZafP6nbYGk5MKxll1GkI/JKesULVmHL0ragX0Qe''
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    allowSFTP = true;
  };

  security.sudo.extraRules = [
    {
      users = [ "thein3rovert-cloud" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  system.stateVersion = "24.11";
}
