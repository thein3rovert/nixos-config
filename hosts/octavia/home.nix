# ==============================
#    Home Manager Configuration
# ==============================
# Home Manager configuration for the wellsjaha test server
# Minimal configuration for testing and development

{ self, inputs, ... }:
{
  # ==============================
  #      Home Manager Setup
  # ==============================
  home-manager.users.thein3rovert =
    { pkgs, ... }:
    {
      # ==============================
      #         Module Imports
      # ==============================
      imports = [
        # Custom home manager modules
        self.homeManagerModules.default
      ];

      # ==============================
      #      Home Configuration
      # ==============================
      home = {
        # User identity
        username = "thein3rovert";
        homeDirectory = "/home/thein3rovert";

        # Minimal package set for testing
        packages = with pkgs; [
          btop # Resource monitor
        ];

        # Home Manager state version
        stateVersion = "25.05";
      };

      # ==============================
      #      Program Configuration
      # ==============================
      programs = {
        # Let Home Manager manage itself
        home-manager.enable = true;
      };

      # ==============================
      #      Custom Module Setup
      # ==============================
      homeSetup = {
        # General programs
        programs.eza.enable = true;

        # User-specific configurations
        thein3rovert = {
          # Shell and CLI tools
          programs.zsh.enable = true;
          programs.starship.enable = true;

          # NOTE: Kitty disabled due to infinite recursion issue
          # programs.kitty.enable = true;
        };
      };
    };
}
