{
  pkgs,
  config,
  lib,
  ...
}:
let

  stdenvNoCC = pkgs.stdenvNocc;
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  If = mkIf;
  createEnableOption = mkEnableOption;
  cfg = config.nixosSetup.profiles.fonts;

in
{
  options.nixosSetup.profiles.fonts = {
    enable = createEnableOption "IoskeleyMono-Hinted Fonts";
    customFonts = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [ ]; # List of font path
      example = [ ../../../../fonts/MyFont ];
      description = "List of local font directories to install";
    };
  };
  config = If cfg.enable {

    fonts.packages = builtins.map (
      src:
      pkgs.stdenvNoCC.mkDerivation {
        pname = "customFonts";
        version = "2.0";
        inherit src;
        # src is not pass an arg
        # src = ../../../../fonts/IoskeleyMono-Hinted;
        installPhase = ''
          mkdir -p $out/share/fonts/truetype/
          cp -r $src/*.{ttf,otf} $out/share/fonts/truetype/
        '';

        # meta = with lib; {
        #   description = "Iosevka-Mono similar to Berkely Mono";
        #   homepage = "https://github.com/ahatem/IoskeleyMono";
        #   platforms = platforms.all;
        # };
      }
    ) cfg.customFonts;
  };
}
