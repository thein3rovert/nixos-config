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
    nixpkgs-unstable-small.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    # Color scheme management
    nix-colors.url = "github:misterio77/nix-colors";

    # Ghostty terminal emulator
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Age-based secret management
    # agenix.url = "github:ryantm/agenix";

    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:yaxitech/ragenix";
    };

    # Zen browser
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

    clan-core = {
      url = "https://git.clan.lol/clan/clan-core/archive/main.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
      nixpkgs-unstable-small,
      clan-core,
      zen-browser,
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
            "bellamy"

            # Managed by incus
            # "lexa" (LXC)

            # Managed by clan
            # "octavia"

            # Managed by Proxmox
            # finn  (Lxc - Killed by grounders)
          ];

        in
        {
          # ==============================
          #         Overlays
          # ==============================
          #  overlays = import ./overlays { inherit inputs; };

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
                  nixpkgs-unstable-small
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
                self.nixosModules.base
                self.nixosModules.snippets
                {
                  nixpkgs.overlays = [ self.overlays.default ];
                }
                # Additional packages
                {
                  environment.systemPackages = [
                    ghostty.packages.x86_64-linux.default
                    agenix.packages.x86_64-linux.default
                  ];
                }

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
          #     NixOS Modules
          # ==============================
          nixosModules = {
            users = ./modules/nixos/users;
            nixosOs = ./modules/nixos/os;
            locale-en-uk = ./modules/nixos/locale/en-uk;
            hardware = ./modules/hardware;
            core = ./modules/core;
            containers = ./modules/nixos/containers;
            snippets = ./modules/snippets;

            # INFO: Contain Reusabke Varibles, Types and more ...
            base = ./modules/base;
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
            #      Node: Bellamy (Prod)
            # ==============================
            bellamy = {
              deployment = {
                targetHost = "bellamy";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [
                  "vps"
                  "production"
                  "prod"
                ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/bellamy
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.nixosOs
                self.nixosModules.users
                self.nixosModules.containers
                self.nixosModules.snippets
                self.nixosModules.base
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
            #     Node: Lexa [ lxc 01 ]
            # ==============================
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
                self.nixosModules.containers
                self.nixosModules.nixosOs
                agenix.nixosModules.default
              ];
            };

            # ==============================
            #     Node: Finn [ lxc 02 ]
            # ==============================
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
                self.nixosModules.containers
                self.nixosModules.nixosOs
                self.inputs.home-manager.nixosModules.home-manager
                agenix.nixosModules.default
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
                self.nixosModules.base
                self.nixosModules.containers
                self.nixosModules.snippets
              ];
            };

            # ==============================
            #     Node: Octavia (Prod)
            # ==============================
            octavia = {
              deployment = {
                targetHost = "octavia";
                targetPort = 22;
                targetUser = "thein3rovert";
                buildOnTarget = true;
                tags = [
                  "test"
                  "prod"
                ];
              };
              nixpkgs.system = "x86_64-linux";
              imports = [
                ./hosts/octavia
                agenix.nixosModules.default
                inputs.disko.nixosModules.disko
                self.inputs.home-manager.nixosModules.home-manager
                self.nixosModules.users
                self.nixosModules.nixosOs
                self.nixosModules.hardware
                self.nixosModules.base
              ];
            };
          };
        };
    };
}
