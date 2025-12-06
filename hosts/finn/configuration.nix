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
    settings.PermitRootLogin = "yes";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert"
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
    htop
  ];

  security.sudo.extraRules = [
    {
      users = [ "thein3rovert" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # nixosSetup = {
  #   services = {
  #     ad-guard.enable = true;
  #     tailscale = {
  #       enable = true;
  #     };
  #   };
  # };

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

  # networking.networkmanager.dns = "none";
  # services.resolved.enable = false;
  programs.zsh.enable = true;
  system.stateVersion = "25.05"; # Did you read the comment?
}
