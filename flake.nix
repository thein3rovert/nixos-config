{
  description = ''
    This is a configuration for managing multiple nixos machines
  '';

  # ================================
  #         FLAKE INPUTS
  # ================================
  inputs = {
    # Age-based secret management
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:yaxitech/ragenix";
    };

    # Clan core for machine management
    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Deployment tool for NixOS machines
    colmena.url = "github:zhaofengli/colmena";

    # Declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Flake parts for modular flake organization
    flake-parts.url = "github:hercules-ci/flake-parts";

    # Ghostty terminal emulator
    # ghostty = {
    #   url = "github:ghostty-org/ghostty";
    # };

    # Home Manager for user environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Color scheme management
    nix-colors.url = "github:misterio77/nix-colors";

    # Main nixpkgs repository (unstable channel)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Smaller unstable channel for faster updates
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";

    # Private secrets repository
    secrets = {
      url = "github:thein3rovert/secret-vault";
      flake = false;
    };

    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      agenix,
      clan-core,
      colmena,
      disko,
      flake-parts,
      home-manager,
      nix-colors,
      nixpkgs,
      nixpkgs-unstable-small,
      zen-browser,
      # ghostty,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      # ================================
      #      FLAKE PART CONFIG
      # ================================
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      # Import flake modules
      imports = [
        ./modules/flake
      ];

      flake =
        let
          inherit (self) outputs;

          # ================================
          #      SYSTEM DEFINITIONS
          # ================================
          allSystems = [
            "aarch64-darwin"
            "aarch64-linux"
            "x86_64-darwin"
            "x86_64-linux"
            # NOTE: i686-linux excluded due to agenix compatibility issues
          ];

          # ================================
          #      HELPER FUNCTIONS
          # ================================
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
            "bellamy"
            "demo"
            "nixos"
            "vps-het-1"
            "wellsjaha"

            # Managed by incus
            # "lexa" (LXC)

            # Managed by clan
            # "octavia"

            # Managed by Proxmox
            # finn  (Lxc - Killed by grounders)
          ];
        in
        {
          # ================================
          #      EXTENDED LIB WITH TYPES
          # ================================
          lib = nixpkgs.lib.extend (
            final: prev: {
              t = import ./modules/nixos/os/profiles/types/lib/types.nix { lib = final; };
            }
          );

          # ================================
          #      NIXOS CONFIGURATIONS
          # ================================
          nixosConfigurations = forAllLinuxHosts (
            host:
            self.inputs.nixpkgs.lib.nixosSystem {
              specialArgs = {
                inherit
                  self
                  inputs
                  nix-colors
                  colmena
                  nixpkgs-unstable-small
                  ;
                lib = self.lib;
              };

              modules = [
                # Host-specific configuration
                ./hosts/${host}

                # Core system modules
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager

                # Custom modules
                self.nixosModules.base
                self.nixosModules.containers
                self.nixosModules.core
                self.nixosModules.hardware
                self.nixosModules.nixosOs
                self.nixosModules.snippets
                self.nixosModules.users

                # Overlays
                {
                  nixpkgs.overlays = [ self.overlays.default ];
                }

                # Additional packages
                {
                  environment.systemPackages = [
                    # ghostty.packages.x86_64-linux.default
                    agenix.packages.x86_64-linux.default
                  ];
                }

                # ---- Home-Manager Config ----
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

          # ================================
          #        NIXOS MODULES
          # ================================
          nixosModules = {
            # INFO: Contain Reusable Variables, Types and more ...
            base = ./modules/base;
            containers = ./modules/nixos/containers;
            core = ./modules/core;
            hardware = ./modules/hardware;
            locale-en-uk = ./modules/nixos/locale/en-uk;
            nixosOs = ./modules/nixos/os;
            snippets = ./modules/snippets;
            users = ./modules/nixos/users;
          };

          # ================================
          #           OVERLAYS
          # ================================
          # overlays = import ./overlays { inherit inputs; };

          # ================================
          #    COLMENA DEPLOYMENT CONFIG
          # ================================
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

            # ---- Node: Bellamy (Prod) ----
            bellamy = {
              deployment = {
                targetHost = "bellamy";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [
                  "prod"
                  "production"
                  "vps"
                ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/bellamy
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.base
                self.nixosModules.containers
                self.nixosModules.nixosOs
                self.nixosModules.snippets
                self.nixosModules.users
              ];
            };
            # ---- Node: Bellamy (Prod) ----
            marcus = {
              deployment = {
                targetHost = "10.10.10.13";
                targetPort = 22;
                targetUser = "in3rovert";
                buildOnTarget = true;
                tags = [
                  "prod"
                  "production"
                  "bare-metal"
                ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/marcus
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.base
                self.nixosModules.containers
                self.nixosModules.nixosOs
                self.nixosModules.snippets
                self.nixosModules.users
              ];
            };

            # ---- Node: Demo ----
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

            # ---- Node: Finn [ lxc 02 ] ----
            finn = {
              deployment = {
                targetHost = "10.10.10.10";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [ "homelab" ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/finn
                agenix.nixosModules.default
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.containers
                self.nixosModules.nixosOs
              ];
            };

            # ---- Node: Lexa [ lxc 01 ] ----
            lexa = {
              deployment = {
                targetHost = "10.135.108.10";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [ "test" ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/lexa
                agenix.nixosModules.default
                self.nixosModules.users
                self.nixosModules.containers
                self.nixosModules.nixosOs
                self.nixosModules.snippets
                self.inputs.home-manager.nixosModules.home-manager
              ];
            };

            # ---- Node: Octavia (Prod) ----
            octavia = {
              deployment = {
                targetHost = "octavia";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [
                  "prod"
                  "test"
                ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/octavia
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.base
                self.nixosModules.hardware
                self.nixosModules.nixosOs
                self.nixosModules.users
                self.nixosModules.snippets
              ];
            };

            # ---- Node: VPS-HET-1 ----
            vps-het-1 = {
              deployment = {
                targetHost = "vps-het-1";
                targetPort = 22;
                targetUser = "thein3rovert-cloud";
                buildOnTarget = true;
                tags = [
                  "production"
                  "vps"
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

            # ---- Node: Wellsjaha (Test) ----
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
                self.nixosModules.base
                self.nixosModules.containers
                self.nixosModules.hardware
                self.nixosModules.nixosOs
                self.nixosModules.snippets
                self.nixosModules.users
              ];
            };
          };
        };
    };
}
