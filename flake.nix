{
  description = ''
    This is a configuration for managing multiple nixos machines
  '';

  # ==============================
  #        Flake Inputs
  # ==============================
  inputs = {
    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Main nixpkgs repository (unstable channel)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Color scheme management
    nix-colors.url = "github:misterio77/nix-colors";

    # Ghostty terminal emulator
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Age-based secret management
    agenix.url = "github:ryantm/agenix";

    # Zen browser
    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Private secrets repository
    secrets = {
      url = "github:thein3rovert/secret-vault";
      flake = false;
    };

    # Deployment tool for NixOS machines
    colmena.url = "github:zhaofengli/colmena";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      home-manager,
      nixpkgs,
      nix-colors,
      ghostty,
      agenix,
      disko,
      colmena,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # ============================
      # Flake Part Config
      # ============================
      systems = [
        "aarch64-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # Import flake modules
      imports = [
        ./modules/flake
      ];

      flake =
        let
          inherit (self) outputs;

          # ==============================
          #      System Definitions
          # ==============================
          allSystems = [
            "aarch64-linux"
            "x86_64-linux"
            "aarch64-darwin"
            "x86_64-darwin"
            # NOTE: i686-linux excluded due to agenix compatibility issues
          ];

          # ==============================
          #      Helper Functions
          # ==============================
          # Defines a function called 'forAllSystems' that takes a function 'f' as an argument
          forAllSystems =
            f:
            # Calls 'genAttrs' from nixpkgs' lib to generate an attribute set for all systems in 'allSystems'
            self.inputs.nixpkgs.lib.genAttrs allSystems (
              system:
              # For each system, call the function 'f' with a set containing 'pkgs'
              f {
                # 'pkgs' is Nixpkgs imported for the current system, with overlays and unfree packages allowed
                pkgs = import self.inputs.nixpkgs {
                  inherit system;
                  config.allowUnfree = true;
                };
              }
            );

          # Helper function to generate configurations for all Linux hosts
          forAllLinuxHosts = self.inputs.nixpkgs.lib.genAttrs [
            "nixos"
            "demo"
            "vps-het-1"
            "wellsjaha"
          ];
        in
        {
          # ==============================
          #         Overlays
          # ==============================
          overlays = import ./overlays { inherit inputs; };

          # ==============================
          #    NixOS Configurations
          # ==============================
          nixosConfigurations = forAllLinuxHosts (
            host:
            self.inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit
                  self
                  inputs
                  nix-colors
                  colmena
                  ;
              };

              modules = [
                # Host-specific configuration
                ./hosts/${host}

                # Core system modules
                self.inputs.home-manager.nixosModules.home-manager
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko

                # Custom modules
                self.nixosModules.users
                self.nixosModules.nixosOs
                self.nixosModules.hardware
                self.nixosModules.core
                self.nixosModules.containers

                # Additional packages
                { environment.systemPackages = [ ghostty.packages.x86_64-linux.default ]; }

                # ==============================
                #    Home-Manager Config
                # ==============================
                {
                  home-manager = {
                    backupFileExtension = "backup";
                    extraSpecialArgs = { inherit self; };
                    useGlobalPkgs = true;
                    useUserPackages = true;
                  };
                  nixpkgs = {
                    config.allowUnfree = true;
                  };
                }
              ];
            }
          );

          # ==============================
          #     Development Shells
          # ==============================
          # devShells = forAllSystems (
          #   { pkgs }:
          #   {
          #     # Default development shell with all required tools
          #     default = pkgs.mkShell {
          #       packages =
          #         (with pkgs; [
          #           # Code formatting and linting
          #           alejandra
          #           nixd
          #           nil
          #           bash-language-server
          #           nodePackages.prettier
          #
          #           # Shell script tools
          #           shellcheck
          #           shfmt
          #
          #           # General utilities
          #           nix-update
          #           git
          #           ripgrep
          #           sd
          #           fd
          #           pv
          #           fzf
          #           bat
          #
          #           # Networking tools
          #           nmap
          #
          #           # Cache building requirements
          #           python3
          #           python3Packages.wcwidth
          #         ])
          #         ++ [
          #           # Age secret management
          #           self.inputs.agenix.packages.${pkgs.system}.default
          #         ];
          #     };
          #   }
          # );

          # ==============================
          #   Home Manager Modules
          # ==============================
          # NOTE: Ignore error "unknown flake output 'homeManagerModules'" as it's not in use yet
          # homeManagerModules = {
          #   thein3rovert = ./homes/thein3rovert;
          #   thein3rovert-cloud = ./home/thein3rovert-cloud;
          #   default = ./modules/home;
          # };

          # ==============================
          #     NixOS Modules
          # ==============================
          nixosModules = {
            users = ./modules/nixos/users;
            nixosOs = ./modules/nixos/os;
            locale-en-uk = ./modules/nixos/locale/en-uk;
            hardware = ./modules/hardware;
            core = ./modules/core;
            containers = ./modules/nixos/containers;
          };

          # ==============================
          #   Colmena Deployment Config
          # ==============================
          colmenaHive = colmena.lib.makeHive {
            # Global configuration for all nodes
            meta = {
              nixpkgs = import nixpkgs {
                system = "x86_64-linux";
              };
              specialArgs = {
                inherit
                  self
                  inputs
                  nix-colors
                  ;
              };
            };

            # ==============================
            #        Node: Demo
            # ==============================
            demo = {
              deployment = {
                targetHost = "demo";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [ "homelab" ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/demo
                inputs.disko.nixosModules.disko
                self.nixosModules.nixosOs
              ];
            };

            # ==============================
            #      Node: VPS-HET-1
            # ==============================
            vps-het-1 = {
              deployment = {
                targetHost = "vps-het-1";
                targetPort = 22;
                targetUser = "thein3rovert-cloud";
                buildOnTarget = true;
                tags = [
                  "vps"
                  "production"
                ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/vps-het-1
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.nixosOs
              ];
            };

            # ==============================
            #     Node: Wellsjaha (Test)
            # ==============================
            wellsjaha = {
              deployment = {
                targetHost = "wellsjaha";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [ "test" ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/wellsjaha
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.users
                self.nixosModules.nixosOs
                self.nixosModules.hardware
              ];
            };
          };
        };
    };
}
