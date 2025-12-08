{ pkgs, ... }:
{

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;
    users.thein3rovert = ./home.nix;
    backupFileExtension = "backup";
  };

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO"
  ];

  users.users.thein3rovert = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    # Add ssh keys
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert"
    ];
  };
  environment.systemPackages = with pkgs; [
    vim
    tcpdump
    htop
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

  nixosSetup = {
    services = {
      ad-guard.enable = true;
      tailscale = {
        enable = true;
      };
    };
  };
  # Add to your LXC's NixOS config
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # Use "loose" instead of false
    trustedInterfaces = [ "tailscale0" ];
  };
  nix.settings = {
    sandbox = false;
    trusted-users = [
      "root"
      "thein3rovert"
    ];
  };
  # services.logrotate.enable = false;
  # networking.nameservers = [
  #   # Default (Adguard)
  #   "10.135.108.10"
  # ];

  # networking.interfaces.eth0 = {
  #   useDHCP = false;
  #   ipv4.addresses = [
  #     {
  #       address = "10.135.108.203";
  #       prefixLength = 24;
  #     }
  #   ];
  # };

  # networking.defaultGateway = "10.135.108.1";

  # Disable router DNS
  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
    '';
  };
  # networking.networkmanager.dns = "none";
  # services.resolved.enable = false;
  programs.zsh.enable = true;
  system.stateVersion = "25.05"; # Did you read the comment?
}
