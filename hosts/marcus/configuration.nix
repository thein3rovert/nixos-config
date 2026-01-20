{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "marcus"; # Change this
  networking.networkmanager.enable = true;

  # Locale
  time.timeZone = "Europe/London"; # Change as needed
  i18n.defaultLocale = "en_GB.UTF-8";
  console.keyMap = "us";

  users.users.thein3rovert = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];

    /*
      NOTE:
      Fixes home-manager not showing after enabled error.
      These is a temp fix, not best practise as t's mixing
      system-level and home-manager package management.

      This is used when using a system level home-manager instead of
      standalone, so home-manager packagea are installed but it doesnt show
      home-manager on path when we run `which home-manager`.autoSubUidGidRange
      It's also been added to the base user if in any case the a specfic server enable
      base use config
    */
    packages = [ inputs.home-manager.packages.${pkgs.stdenv.hostPlatform.system}.default ];

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert"
    ];
  };
  ## For updating my driver
  boot.extraModulePackages = with config.boot.kernelPackages; [ rtw88 ];
  boot.kernelParams = [
    "rtw_8821ce.disable_msi=1"
    "rtw_8821ce.disable_aspm=1"
  ];
  security.sudo.extraRules = [
    {
      users = [
        "thein3rovert"
        "root"
      ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];
  security.sudo.wheelNeedsPassword = false;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO"
  ];
  # SSH for remote management
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # Fix poweroff on led close
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";

  # Basic packages
  environment.systemPackages = with pkgs; [
    vim
    git
    fastfetch
  ];

  system.stateVersion = "25.05";
}
