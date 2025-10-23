{ self, inputs, ... }:
{
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {
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
