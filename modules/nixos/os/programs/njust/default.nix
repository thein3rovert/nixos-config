{
  config,
  lib,
  pkgs,
  ...
}:
let

  inherit (lib)
    concatStringsSep
    attrValues
    ;

  concatenateString = concatStringsSep;
  attributeValues = attrValues;

  cfg = config.nixosSetup.programs.njust;

  mergeContentIntoJustFile = ''

    -default:
      @printf '\033[1;36mnjust\033[0m\n'
      @printf 'Just-based recipe runner for NixOS.\n\n'
      @printf '\033[1;33mUsage:\033[0m njust <recipe> [args...]\n\n'
      @njust --list --list-heading $'Available recipes:\n\n'
    # Concatenante all recipe content from cfg.recipes attribites set
    ${concatenateString "\n" (attributeValues cfg.recipes)} 
  '';

in
{

}
