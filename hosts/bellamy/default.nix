# ==============================
#     Bellamy Host Configuration
# ==============================
# Production server configuration

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
  networking.hostName = "Bellamy";

  # ==============================
  #     Network Configuration
  # ==============================

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
  ];

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
