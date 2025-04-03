{
  # Input arguments for the module
  lib,
  config,
  pkgs,
  ...
}:
with lib; # Import lib namespace for helper functions
let
  # Create shorthand reference to font configuration
  cfg = config.nmod.fonts;
in
{
  # Define configuration options for the fonts module
  options.nmod.fonts = {
    extra = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = "List of additional fonts to install";
    };
    nerd = mkEnableOption "Nerd Fonts"; # Toggle for Nerd Fonts
    emoji = mkEnableOption "Emoji"; # Toggle for Emoji fonts
  };

  config =
    let
      # Define set of emoji fonts to install when enabled
      emoji = with pkgs; [
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-extra
      ];
      # Define set of nerd fonts to install when enabled
      nerd = with pkgs; [
        carlito
        ipafont
        kochi-substitute
        source-code-pro
        ttf_bitstream_vera
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.jetbrains-mono
      ];
    in
    {
      fonts = {
        fontconfig.useEmbeddedBitmaps = true;
        # Combine base fonts with conditionally enabled font sets
        packages = [
          pkgs.dejavu_fonts
        ] ++ (lib.optionals cfg.emoji emoji) ++ (lib.optionals cfg.nerd nerd);
      };
    };
}
