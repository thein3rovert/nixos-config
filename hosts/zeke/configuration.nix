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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObli1unUWlbZaja5VMzTIvPBJOCI/E6vs/qhrVkSHLO thein3rovert"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEiYYJN/Zy38lnIdx1C1I9kQOtgKQTaTt7/bagchFrxN danielolaibi@gmail.com"
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
    programs = {
      podman.enable = true;
    };
    services = {
      technitium.enable = true;
      tailscale.enable = true;
    };
  };

  # Free port 53 for Technitium by disabling the systemd-resolved stub listener
  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        DNSStubListener = "no";
      };
    };
  };

  # LXC-specific firewall: loose reverse-path filtering so DNS replies over
  # Tailscale aren't dropped. Ports are opened by the technitium/tailscale modules.
  networking.firewall = {
    enable = true;
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
  };

  nix.settings = {
    sandbox = false;
    trusted-users = [
      "root"
      "thein3rovert"
    ];
  };

  programs.zsh.enable = true;
  system.stateVersion = "25.05";
}
