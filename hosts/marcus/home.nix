{ self, inputs, ... }:
let

  customImport = self.homeManagerModules.default;
in
{
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {

      # ==============================
      #         Module Imports
      # ==============================
      imports = [
        customImport
      ];

      # ------------------------------
      # HOME USER
      # ------------------------------
      home = {
        username = "thein3rovert";
        homeDirectory = "/home/thein3rovert";

        # ------------------------------
        # HOME PACKAGES
        # ------------------------------
        packages = with pkgs; [
          vim
        ];
        stateVersion = "25.05";
      };

      homeSetup.programs.agent.enable = true;
      # ------------------------------------
      # PROGRAM
      # -------------------------------------
      programs = {
        home-manager.enable = true;
      };
    };
}
