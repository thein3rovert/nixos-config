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
    escapeShellArg
    ;

  concatenateString = concatStringsSep;
  attributeValues = attrValues;
  escapeShellArgument = escapeShellArg;

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

  # Validate justFile syntax at build times, help to revent proken just files
  validatedJustfile =
    pkgs.runCommand "njust-justfile-validated"
      {
        nativeBuildInput = [ pkgs.just ];
        preferLocalBuild = true;
      }
      ''
        # Write the merged justfile content to a temporary file
        echo ${escapeShellArgument mergeContentIntoJustFile} > justfile 

        # Validate justfile syntac using 'just --summary'

        echo "Validating njust cli justfile syntax..."
        just --justfile justfile --summary >/dev/null || {
            echo "ERROR: njust justfile has syntax errors!"
            echo "justfile content:"
            cat justfile
            exit 1
          }
        # Coyp validated justfile to the nix store output path
        cp justfile $out
        echo "njust justfile validation successful"
      '';

  mergedJustfile = validatedJustfile;

  njustScript = pkgs.writeShellApplication {
    name = "njust";
    runtimeInputs = [
      pkgs.jq
      pkgs.just
    ];
    text = ''
      # Execute 'just' with the merged justfile, preserving current directory
      exec just --working-directory "$PWD" --justfile ${mergedJustfile} "$@"
    '';
  };
in
{

}
