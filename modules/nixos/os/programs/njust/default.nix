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
    mkEnableOption
    mkOption
    types
    mkIf
    ;
  # Library Options
  createOption = mkOption;
  createEnableOption = mkEnableOption;
  concatenateString = concatStringsSep;
  attributeValues = attrValues;
  escapeShellArgument = escapeShellArg;
  If = mkIf;

  # Types
  boolean = types.bool;
  string = types.str;
  attributeSet = types.attrsOf;
  cfg = config.nixosSetup.programs.njust;

  # Merge All of Just Content into just file
  # Concatenante all recipe content from cfg.recipes attribites set
  mergeContentIntoJustFile = ''
    _default:
      @printf '\033[1;36mnjust\033[0m\n'
      @printf 'Just-based recipe runner for NixOS.\n\n'
      @printf '\033[1;33mUsage:\033[0m njust <recipe> [args...]\n\n'
      @njust --list --list-heading $'Available recipes:\n\n'

    ${concatenateString "\n" (attributeValues cfg.recipes)} 
  '';

  # Validate justFile syntax at build times, help to revent proken just files
  validatedJustfile =
    pkgs.runCommand "njust-justfile-validated"
      {
        nativeBuildInputs = [ pkgs.just ];
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
  options.nixosSetup.programs.njust = {
    enable = createEnableOption "njust cli helper";

    recipes = createOption {
      type = attributeSet string;
      default = { };
      description = ''
        Attributes set of recipe names to justfile content.
        Each recipe will be merged into final justfile.
      '';
    };

    # Whether to include built-in system management recipes
    baseRecipes = createOption {
      type = boolean;
      default = true;
      description = "Include default system management recipes?";
    };
  };

  config = If cfg.enable {
    nixosSetup.programs.njust.recipes = If cfg.baseRecipes {

      system = ''
        # Show system info 
        [group('system')]
        info:
          @echo "Hostname: $(hostname)"
          @echo "Nixos Version: $(nixos-version)"
          @echo "Kernel: $(uname -r)"
          @echo "Generation: $(sudo nix-env --list-generations -p /nix/var/nix/profiles/system | tail -1 | awk '{print $1}')"
          @echo "Revison: $(nixos-version --json | jq -r '.configurationRevision // "unknown"')"
      '';
    };
    environment.systemPackages = [ njustScript ];
  };

}
