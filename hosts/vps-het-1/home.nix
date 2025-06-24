{ self, inputs, ... }:
{
  home-manager.users.thein3rovert-cloud =
    { pkgs, ... }:
    {
      imports = [
        # INFO: THESE HAVENT BE CREATED YET, they should first be created in the flake before import
        # self.homeManagerModules.default
        # self.inputs.agenix.homeManagerModules.default
      ];

      home = {
        homeDirectory = "/home/thein3rovert-cloud";

        packages = with pkgs; [

          btop
        ];

        stateVersion = "25.05";
        username = "thein3rovert-cloud";
      };
      programs = {
        # helix = {
        #   enable = true;
        #   defaultEditor = true;
        # };

        home-manager.enable = true;
      };

    };
}
