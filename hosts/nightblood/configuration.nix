{ pkgs, ... }:
{
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "prohibit-password";
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiYYJN/Zy38lnIdx1C1I9kQOtgKQTaTt7/bagchFrxN danielolaibi@gmail.com"
    ];
  };
  environment.systemPackages = with pkgs; [
    vim
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
      tailscale.enable = true;
    };
  };

  # Add to your LXC's NixOS config
  networking.firewall = {
    enable = true;
    checkReversePath = "loose"; # Use "loose" instead of false
    trustedInterfaces = [ "tailscale0" ];
    allowedTCPPorts = [ 2049 ];
    allowedUDPPorts = [ 2049 ];
  };

  services.nfs.server = {
    enable = true;
    exports = ''
      /srv/nfs 192.168.0.0/24(rw,sync,no_subtree_check,root_squash)
    '';
  };

  nix.settings = {
    trusted-users = [
      "root"
      "thein3rovert"
    ];
  };
  system.stateVersion = "25.05";
}
