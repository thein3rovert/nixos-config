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

      # ------------------------------
      # HOME USER
      # ------------------------------
      home = {
        username = "thein3rovert-cloud";
        homeDirectory = "/home/thein3rovert-cloud";

        # ------------------------------
        # HOME PACKAGES
        # ------------------------------
        packages = with pkgs; [
          btop
        ];
        stateVersion = "25.05";
      };

      # ------------------------------------
      # PROGRAM
      # -------------------------------------
      programs = {
        home-manager.enable = true;
      };
    };
}
