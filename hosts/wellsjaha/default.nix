# ==============================
#     Wellsjaha Host Configuration
# ==============================
# Test server configuration for development and experimentation
# Reference: Host "fallarbor" aly

{
  config,
  self,
  pkgs,
  modulesPath,
  ...
}:

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
    ./secrets.nix

    # Custom modules
    self.nixosModules.locale-en-uk
  ];

  # ==============================
  #      System Configuration
  # ==============================
  system.stateVersion = "25.05";
  networking.hostName = "wellsjaha";

  # ==============================
  #     Network Configuration
  # ==============================
  # Static IP configuration
  networking.interfaces.enp1s0 = {
    useDHCP = false;
    ipv4.addresses = [
      {
        address = "10.20.0.1";
        prefixLength = 16;
      }
    ];
  };

  # Network routing and DNS
  networking.defaultGateway = "10.20.0.254";
  networking.nameservers = [
    "10.10.10.12"
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
    btop # System monitor
    python3
    dig
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
    services = {
      linkding.enable = true;
      traefikk.enable = true;

      tailscale = {
        enable = true;
      };

      audiobookshelf = {
        enable = false;
        audiobookshelf-ts-authKeyFile = config.age.secrets.audiobookshelf.path;
      };
    };

    # Program configurations
    programs = {
      podman.enable = true;
      vscode.enable = false;
      vscode.enableFhs = true;
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
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
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
            **++===--:::::@@@@@@@@@@@@::::-:--........  
            *+=====--::@@@@@@@@@@@@@@@@@@:::-:........  
            +++==---:@@@@@@@@@@@@@@@@@@@@@::-.........  
            +++==-:.@@@@@@@@@@@@@@@@@@@@@@@::...::....  
            ++===..:@@@@@@@#******####%%@@@:::---=....  
            +=+=::--@@@@@%###***++**##%%%@@::---==....  
            =+=:=..:@@@@%####*+====+**##%%@::--===....  
            =.-+=:-=@@@%###%%%#%+++*%%**%%@-:--=+:....  
            --++:--*@@@####%@@###+*%#%@+@%@--===+.....  
            :--:==+#@#@###**+#***+*##*##*##==+++......  
            :::-=++*##%%#*+==+**#**#%#*+*#%%=+*-::::::  
            .:::==+*@*#%%#*+==+*@#*#%#***#%%***:::::::  
            :..::-=+@##%###****#****%%###%%*###=:::-::  
            ...::==+@@@%#####@%%%%##%%@#%%%%##%*:::---  
            ...:::-=*@@%%%#%#*##+=+=#%#%@@#%%%%%:::---  
            ....:-::+#%=%@%%%#**#######%@%#%%%%@-::---  
            ...::-::.:@:#%%%%%##**+*##%@%@%%%@@@-::---  
            .:::---=@@@:..=##%@%%%%%%@@#:@@@@@@@=::--=  
            .::-@@@@@@@@.....+*#####%##.:%@@@@@@=:::--  
            @@@@@@@@@@@@-.......+####...:+@@@@@@@@@=--  
            @@@@@@@@@@@@@:........:-*...:=@@@@@@@@@@@@  
            @@@@@@@@@@@@@%......@@@@@@:=::@@@@@@@@@@@@  
            @@@@@@@@@@@@@@:...::@@@@@@:..-@@@@@@@@@@@@  
            @@@@@@@@@@@@@@@:::::..@@@@@--:@@@@@@@@@@@@  
            @@@@@@@@@@@@@@@*.::....@@@@.::@@@@@@@@@@@@  
            @@@@@@@@@@@@@@@@:...:.:@@@@@.:@@@@@@@@@@@@  
            @@@@@@@@@@@@@@@@@.:.:.@@@@@@@:%@@@@@@@@@@@  
            @@@@@@@@@@@@@@@@@@:.-.@@@@@@@:%@@@@@@@@@@@  
        __     __     ______     __         __         ______    
      /\ \  _ \ \   /\  ___\   /\ \       /\ \       /\  ___\   
      \ \ \/ ".\ \  \ \  __\   \ \ \____  \ \ \____  \ \___  \  
       \ \__/".~\_\  \ \_____\  \ \_____\  \ \_____\  \/\_____\ 
        \/_/   \/_/   \/_____/   \/_____/   \/_____/   \/_____/ 
                                                                                             
                   Welcome to WellsJaha (NixOS) 🚀
    '';
  };

  # ==============================
  #     Nixpkgs Configuration
  # ==============================
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
}
