{
  config,
  pkgs,
  lib,
  self,
  ...
}:
{
  imports = [ self.homeManagerModules.default ];

  config = {
    # Basic home configuration
    home = {
      username = "thein3rovert";
      homeDirectory = "/home/thein3rovert";
      stateVersion = "25.11";

      packages = with pkgs; [
        # Core utilities
        # curl
        cowsay
        # wget
        # git
        # htop
        # btop
        # tree
        # fd
        # ripgrep
        # jq
        # unzip
        # zip
        #
        # WSL-specific tools
        # wslu # WSL utilities (wslview, etc.)

        # Development tools
        # neovim
        # tmux
        # fzf
        # eza
        bat
        zoxide
      ];

      sessionVariables = {
        EDITOR = "nvim";
        BROWSER = "wslview";
        # Fix for WSL2 interop
        WSLENV = "";
        DISPLAY = ":0";
      };

      # Enable bash completion for system packages
      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    # Enable Home Manager
    programs.home-manager.enable = true;

    # SSH client configuration for easy access
    # programs.ssh = {
    #   enable = true;
    #   addKeysToAgent = "yes";
    #   matchBlocks = {
    #     # Allow SSH agent forwarding if needed
    #     "*" = {
    #       forwardAgent = true;
    #     };
    #   };
    # };
    #
    # Enable SSH agent service
    # services.ssh-agent.enable = true;

    # Git configuration (basic)
    # programs.git = {
    #   enable = true;
    #   userName = "thein3rovert";
    #   # userEmail = "your-email@example.com"; # TODO: Uncomment and update this
    #   extraConfig = {
    #     init.defaultBranch = "main";
    #     push.autoSetupRemote = true;
    #     core.editor = "nvim";
    #   };
    # };
    #
    # Shell configuration
    # programs.bash = {
    #   enable = true;
    #   enableCompletion = true;
    #   shellAliases = {
    #     # WSL-specific aliases
    #     explorer = "wslview";
    #     open = "wslview";
    #     code = "wslview code";
    #
    #     # Common aliases
    #     ll = "ls -la";
    #     la = "ls -a";
    #     ".." = "cd ..";
    #     "..." = "cd ../..";
    #
    #     # Nix helpers
    #     nix-switch = "home-manager switch --flake ~/nixos-config#thein3rovert@wsl";
    #     nix-update = "nix flake update --flake ~/nixos-config && home-manager switch --flake ~/nixos-config#thein3rovert@wsl";
    #   };
    # };
    #
    # Enable ZSH with your existing config

    # XDG directories
    xdg.enable = true;

    # Allow unfree packages
    nixpkgs.config.allowUnfree = true;
  };
}
