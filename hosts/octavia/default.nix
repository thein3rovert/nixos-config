# ==============================
#     Octavia Host Configuration
# ==============================
{
  config,
  self,
  pkgs,
  modulesPath,
  lib,
  ...
}:
let
  inherit (lib)
    mkForce
    ;

  force = mkForce;
in

{
  # ==============================
  #         Module Imports
  # ==============================
  imports = [
    # Hardware detection and QEMU guest support
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")

    # Host-specific configurations
    ./disk-config.nix
    ./home.nix
    # ./secrets.nix

    # Custom modules
    self.nixosModules.locale-en-uk
  ];

  # ==============================
  #      System Configuration
  # ==============================
  system.stateVersion = "25.05";
  networking.hostName = "octavia";

  # ================================================================
  # Network Configuration
  # Disable NetworkManager - not needed for server VMs
  # Saves ~60-70MB RAM
  # ================================================================
  networking.networkmanager.enable = force false;
  networking.wireless.enable = force false; # Also disable wpa_supplicant

  # ==============================
  #     Network Configuration
  # ==============================
  # Static IP configuration
  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.20.0.2";
        prefixLength = 16;
      }
    ];
  };

  # Network routing and DNS
  networking.defaultGateway = "10.20.0.254";
  networking.nameservers = [
    "1.1.1.1"
    "8.8.8.8"
  ];

  # ==============================
  #      Time & Locale Setup
  # ==============================
  time.timeZone = "Europe/London";
  console.keyMap = "uk";

  # ==============================
  #      Boot Configuration
  # ==============================
  boot.loader.grub = {
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  # ==============================
  #       System Packages
  # ==============================
  environment.systemPackages = with pkgs; [
    btop
    python3
  ];

  # ==============================
  #     Hardware Configuration
  # ==============================
  hardwareSetup.intel.cpu.enable = true;

  # ==============================
  #      Custom Module Setup
  # ==============================
  nixosSetup = {
    # Base system profile
    profiles = {
      base.enable = true;
      server.enable = true;
    };

    # Program configurations
    programs = {
      podman.enable = true;
      vscode.enable = false;
      vscode.enableFhs = false;
    };
  };

  # ==============================
  #       QEMU Guest Services
  # ==============================
  services.qemuGuest.enable = true;

  # ==============================
  #       User Management
  # ==============================
  # Users configured with yescrypt password hashing
  myUsers = {
    thein3rovert = {
      enable = true;
      password = "$6$eZ8tBXlSXhG5Ry78$pJPlB/w0jrWJppTi7b10dH6C9gQGfmWyqIdMkGxGrp/HrYTU7AwNK7lsTNvlz8byr9nflqZfykYsTtch.Jr0C0";
    };
  };

  # ==============================
  #      SSH Configuration
  # ==============================
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    allowSFTP = true;
    banner = ''
      %%%%%%%%%%%@%@@@@%@@@@@@@@@@@@%%%%%%%%%%%%
      %%%%%%%%%@%%@@@%#@%@@@@@@@@@@@@@%%%%%%%%%%
      %%%%%%%@%#%@@@%%#%%%@@@@@@@@@@@@@%%%%%%%%%
      %%%%%%%%##%@@%*%%##%%#%%%@@@@@@@@@%%%%%%%%
      %%%%%%%%%%@@#*=----=+**%%@@@@@@@@@@%%%%%%%
      %%%%%%%%%@@%+-:::::----=*#%#@@@@@@@@%%%%%%
      %%%%%@%@%@@=---::-----==+*#%@@@@@@@@@%%%%%
      %%%%%@@@%@%--:::::::----=+*#@@@@@@@@@%%%%%
      %%%%%@@@@@#-+%@#=---=#%%%#*%%@@@@@@@@@%%%%
      %%%%%@@@@@#%@#@*+--+###.%@@%%@@@@@@@@@@%%%
      %%%%%@@@@@*------::++-=++*++#%@@@@@@@@@%%%
      %%%%%@@@@@+-:::----*+=----=*%@@@@@@@@@@@%%
      %%%%@@@@@@*=-::----***--==*#%@@@%%@@@@@@%%
      %%%@@@@@@@#==--:--+*+===+*#%%@@@%@@@@@@@%%
      %%%%@@@@@@@+===-===+++++*##%%@@@@%@@@@@@%%
      %%%%%@@@@%@@*==-+===**+**%%@@@@@%@@@@@@@%%
      %%%%%@%@@@%@@@=-----==*#%@@@@@@@%#@%@@@@%%
      %%%@%@%@@@#@@@@+---==+%@@@@%@@@%@#%@%%%@%%
      %%%%%%%%%@#@@@@+==++**##%%%@@@@@@@%@%%%%%%
      %%%%%%##%@#@@@@*-=====+#%@@@@@@@@@@%@@@%@%
      %%%%@##%%@#@@@@*--====#%%%@@@#@@@@@@@@@@@@
      %%%@%%#@%@@@@@%*=--=-*#+%%@@%@@@@@@@@@@@@@
      %%@@@@%%@%@@@%*=-----*=+@@@%%@@@@@@@@@@@@%
      %@@%@%@%@@@%%%+------#+%@@@%@@@@@%@%@@@@@%
      @%%@%##%@@@@%#+-------+@@@@@%%@@@@#%@@@@@%
             ______     ______     ______   ______     __   __   __     ______
            /\  __ \   /\  ___\   /\__  _\ /\  __ \   /\ \ / /  /\ \   /\  __ \
            \ \ \/\ \  \ \ \____  \/_/\ \/ \ \  __ \  \ \ \'/   \ \ \  \ \  __ \
             \ \_____\  \ \_____\    \ \_\  \ \_\ \_\  \ \__|    \ \_\  \ \_\ \_\
              \/_____/   \/_____/     \/_/   \/_/\/_/   \/_/      \/_/   \/_/\/_/ /_____/

                           Welcome to Octavia (NixOS) 🚀
    '';
  };

  # ==============================
  #     Ebvironment
  # ==============================
  environment.etc."motd".text = ''
     ______     ______     ______   ______     __   __   __     ______
    /\  __ \   /\  ___\   /\__  _\ /\  __ \   /\ \ / /  /\ \   /\  __ \
    \ \ \/\ \  \ \ \____  \/_/\ \/ \ \  __ \  \ \ \'/   \ \ \  \ \  __ \
     \ \_____\  \ \_____\    \ \_\  \ \_\ \_\  \ \__|    \ \_\  \ \_\ \_\
      \/_____/   \/_____/     \/_/   \/_/\/_/   \/_/      \/_/   \/_/\/_/

                Welcome, ${builtins.getEnv "USER"}! 🎉
  '';

  # ==============================
  #     Nixpkgs Configuration
  # ==============================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
