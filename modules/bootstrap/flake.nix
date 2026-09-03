{
  description = "Manage NixOS server remotely";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    colmena.url = "github:zhaofengli/colmena";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      disko,
      colmena,
      nixos-generators,
      ...
    }:
    {
      nixosConfigurations.raven = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          ./configuration.nix
        ];
      };

      packages.x86_64-linux = {
        lxc = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          modules = [
            ./configuration.nix
          ];
          ## If image is for proxmox use (proxmos-lxc)
          ## If image is for incus use (lxc)
          format = "proxmox-lxc";
        };

        # Hoping it works for incus
        # Incus always need an extra meta data details

        # lxc-meta = nixos-generators.nixosGenerate {
        #   system = "x86_64-linux";
        #   pkgs = nixpkgs.legacyPackages.x86_64-linux;
        #   modules = [ ./configuration.nix ];
        #   format = "lxc-metadata";
        # };

      };

      colmenaHive = colmena.lib.makeHive {
        meta = {
          nixpkgs = nixpkgs.legacyPackages.x86_64-linux;
        };
        defaults =
          { pkgs, ... }:
          {
            environment.systemPackages = [
              pkgs.curl
              pkgs.htop
            ];
          };
        raven =
          { pkgs, ... }:
          {
            # INFO: This was used for when i was building a custom runner
            # for forgejo, just writing this so i dont forget..haha
            deployment = {
              targetHost = "raven"; # runner
              targetPort = 22;
              targetUser = "thein3rovert";
              buildOnTarget = true;
              tags = [ "homelab" ];
            };
            nixpkgs.system = "x86_64-linux";
            imports = [
              disko.nixosModules.disko
              ./configuration.nix
            ];
            time.timeZone = "Europe/London";
          };
      };
    };
}
