# INFO: This is means to be used with the standalone
# home-manager but because that is not in use now i
# will just keep these tills its needed
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
          htop
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
