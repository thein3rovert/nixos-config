{
  description = ''
    This is a configiration for managing multiple nixos machines
  '';

  # === Flake Inputs ===
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    nix-colors.url = "github:misterio77/nix-colors";

    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    agenix.url = "github:ryantm/agenix";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # colmena = {
    #   url = "github:zhaofengli/colmena";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    colmena.url = "github:zhaofengli/colmena";
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
      ...
    }@inputs:
    let
      inherit (self) outputs;
      allSystems = [
        "aarch64-linux"

        # --- Causing issues with github action and agenix ---
        # Agenix does not provide package for i686
        # "i686-linux"

        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      # forAllSystems = nixpkgs.lib.genAttrs systems;

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
              inherit system; # Use overlays and current system architecture
              config.allowUnfree = true;
            };
          }
        );

      forAllLinuxHosts = self.inputs.nixpkgs.lib.genAttrs [
        "nixos"
        "demo"
        "vps-het-1"
        "wellsjaha"
      ];
    in
    {
      overlays = import ./overlays { inherit inputs; };

      # === Nixos Configurations for all hosts ===
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

          # === Modules ===
          modules = [
            ./hosts/${host}
            self.inputs.home-manager.nixosModules.home-manager
           # agenix.nixosModules.default
            { environment.systemPackages = [ ghostty.packages.x86_64-linux.default ]; }
            inputs.disko.nixosModules.disko
            self.nixosModules.users

            # === Custom Modules ===
            self.nixosModules.nixosOs
            self.nixosModules.hardware
            self.nixosModules.core

            # === Home-Manager Config ===
            # Managing home-manager as part of nixos config
            {
              home-manager = {
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit self; };
                useGlobalPkgs = true;
                useUserPackages = true;
              };
              nixpkgs = {
                # inherit overlays;
                config.allowUnfree = true;
              };
            }
          ];
        }
      );
      devShells = forAllSystems (
        { pkgs }:
        {

          # mkShell is a function that setup a temporary enviroment
          # with the specified packages
          default = pkgs.mkShell {
            packages =
              (with pkgs; [
                # --- General Requirements ---
                # nixpkgs-fmt
                alejandra
                nix-update # Updating pkgs
                bash-language-server
                nodePackages.prettier

                # --- Shell Script Tools ---
                shellcheck
                shfmt
                # ----------- Networking ---------
                nmap

                nixd
                nil
                git
                ripgrep
                sd
                fd
                pv
                fzf
                bat

                # --- Requirement for cache building ---
                python3
                python3Packages.wcwidth
              ])
              ++ [
                self.inputs.agenix.packages.${pkgs.system}.default
              ];
          };
        }
      );

      #INFO: Ignore error "unknown flake output 'homeManagerModules'" as
      # it's not in use yet

      # === Home Manager Custom Modules ===
      homeManagerModules = {
        thein3rovert = ./homes/thein3rovert;
        thein3rovert-cloud = ./home/thein3rovert-cloud;
        default = ./modules/home;
      };

      # === Nixos Custom Modules ===
      nixosModules = {
        users = ./modules/nixos/users;
        nixosOs = ./modules/nixos/os;
        locale-en-uk = ./modules/nixos/locale/en-uk;
        hardware = ./modules/hardware;
        core = ./modules/core;
      };

      # === COLMENA CONFIG "Deployment" ===
      colmenaHive = colmena.lib.makeHive {
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

        # -----------------------------------
        # DEPLOYMENT
        # -----------------------------------

        # === NODE ONE ===
        demo = {
          deployment = {
            targetHost = "demo";
            targetPort = 22;
            targetUser = "thein3rovert";
            buildOnTarget = true;
            tags = [ "homelab" ]; # TODO: Change tag later
          };
          nixpkgs.system = "x86_64-linux";
          imports = [
            ./hosts/demo
            inputs.disko.nixosModules.disko
            self.nixosModules.nixosOs
            # agenix.nixosModules.defaults
          ];
        };

        # === NODE TWO ===
        vps-het-1 = {
          deployment = {
            targetHost = "vps-het-1"; # Use the actual hostname or IP
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

        # === TEST NODE THREE ===
        wellsjaha = {
          deployment = {
            targetHost = "wellsjaha"; # Use the actual hostname or IP
            targetPort = 22;
            targetUser = "thein3rovert";
            buildOnTarget = true;
            tags = [
              "test"
            ];
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
            # === No Home-Manager ===
            # self.inputs.home-manager.nixosModules.home-manager
          ];
        };
      };

      #  ADDED: New colmenaHive output
      #  colmenaHive = colmena.lib.makeHive self.outputs.colmena;
    };
}
