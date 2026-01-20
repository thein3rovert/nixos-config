# { self, ... }:
_: {
  flake = {
    homeManagerModules = {
      thein3rovert = ../../homes/thein3rovert;
      default = ../home;
    };

    # INFO: Standalone home-manager, doesnt work woth colmena

    # homeConfigurations = {
    #   "thein3rovert@marcus" = self.inputs.home-manager.lib.homeManagerConfiguration {
    #     extraSpecialArgs = { inherit self; };
    #
    #     modules = [
    #       ../../homes/thein3rovert/marcus.nix
    #     ];
    #
    #     pkgs = import self.inputs.nixpkgs {
    #       system = "x86_64-linux";
    #       config.allowUnfree = true;
    #
    #       overlays = [
    #         self.inputs.nixgl.overlay
    #         self.inputs.nur.overlays.default
    #         self.overlays.default
    #       ];
    #     };
    #   };
    # };
  };
}
