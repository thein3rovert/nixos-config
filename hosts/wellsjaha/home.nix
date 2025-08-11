{ self, inputs, ... }:
{
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {
      imports = [

        # INFO: THESE HAVENT BE CREATED YET, they should first be created in the flake before import
        self.homeManagerModules.default

        # self.inputs.agenix.homeManagerModules.default
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

      # ------------------------------------
      # CUSTOM MODULES
      # -------------------------------------
      # TODO: Setup desktop env later

      homeSetup = {
        # desktop.gnome.enable = true;
        thein3rovert = {
          programs.zsh.enable = true;
          packages.cli.enable = true; # Enabled unwanted packages
          programs.starship.enable = true;
          # FIX: Fix infinite recursion issue when enabled
          # programs.kitty.enable = true;
        };
      };
    };
}
