_: {
  perSystem =
    {
      config,
      lib,
      pkgs,
      /*
        Since this is persystem we use
        the system specific version of
        inputs and self.

        This means inputs'.foo.packages.default
        resolves to inputs.foo.packages.${system}.default
      */
      inputs',
      self',
      ...
    }:
    {
      # ==============================
      #     Development Shells
      /*
             Recently moved from main
             flake to flake-parts
      */
      # ==============================

      devShells = {
        # Default development shell with all required tools
        default = pkgs.mkShell {
          packages =
            (with pkgs; [
              # Code formatting and linting
              alejandra
              nixd
              nil
              bash-language-server
              nodePackages.prettier

              # Shell script tools
              shellcheck
              shfmt

              # General utilities
              nix-update
              git
              ripgrep
              sd
              fd
              pv
              fzf
              bat

              # Networking tools
              nmap

              # Cache building requirements
              python3
              python3Packages.wcwidth
            ])
            ++ [
              # Age secret management
              #     inputs'.agenix.packages.default
              # Clan CLI (NEW)
              inputs'.clan-core.packages.clan-cli
            ];

          shellHook = ''
            echo "👋 Welcome to the nixos-config devShell!"
          '';
        };
      };

    };
}
