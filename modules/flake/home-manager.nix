{ self, ... }:
{
  flake = {
    homeConfigurations = {
      "thein3rovert@marcus" = self.inputs.home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = { inherit self; };

        modules = [
          ../../homes/thein3rovert/marcus.nix
        ];

        pkgs = import self.inputs.nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;

          overlays = [
            self.inputs.nixgl.overlay
            self.inputs.nur.overlays.default
            self.overlays.default
          ];
        };
      };
    };

    homeManagerModules = {
      thein3rovert = import ../../homes/thein3rovert;
      # thein3rovert-cloud = ../home/thein3rovert-cloud;
      default = ../home;
    };
  };
}
