{
  modulesPath,
  self,
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

  # === TODO: Add after dynamically allocation require data
  # in modules ===
  nixosSetup = {

    #TODO: Try to replace default podman config
    # to modules config without downtime
    # programs = {
    #   podman.enable = true;
    # };

    services = {
      minio.enable = true;
    };
  };
  nixpkgs.hostPlatform = "x86_64-linux";
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
    # python3
    fastfetch
    micro
    tmux
    neovim
    # ------------------------------
    # CLI (Command Line Interface)
    # ------------------------------
    vim # Text editor
    git # Version control tool
    nix-ld # Nix dynamic library management tool
    nil
    nixd
    nodejs_24

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

  # Enable FHS compatibility for VS Code Server
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
    openssl
    libkrb5
    util-linux
    glibc
  ];

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
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
