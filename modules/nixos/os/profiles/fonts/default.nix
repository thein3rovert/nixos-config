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
  options.nixosSetup.profiles.fonts.enable = createEnableOption "IoskeleyMono-Hinted Fonts";

  config = If cfg.enable {

    fonts.packages = [
      (pkgs.stdenvNoCC.mkDerivation {
        pname = "iosevkaMono";
        version = "2.0";
        src = ../../../../fonts/IoskeleyMono-Hinted;

        installPhase = ''
          mkdir -p $out/share/fonts/truetype/
          cp -r $src/*.{ttf,otf} $out/share/fonts/truetype/
        '';

        meta = with lib; {
          description = "Iosevka-Mono similar to Berkely Mono";
          homepage = "https://github.com/ahatem/IoskeleyMono";
          platforms = platforms.all;
        };
      })
    ];
  };
}
