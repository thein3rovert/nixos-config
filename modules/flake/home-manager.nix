{ self, ... }:
{
  flake = {
    homeManagerModules = {
      thein3rovert = ../../homes/thein3rovert;
      default = ../home;
    };

    # INFO: Standalone home-manager configurations for non-NixOS systems
    # Use with: home-manager switch --flake .#thein3rovert@wsl
    homeConfigurations = {
      "thein3rovert@wsl" = self.inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit self; };

        modules = [
          ../../homes/thein3rovert/wsl.nix
        ];

        pkgs = import self.inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;

          overlays = [
            self.overlays.default
          ];
        };
      };
    };
  };
}
