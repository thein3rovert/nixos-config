# Shared option definitions for agent modules.
# Prevents copy-pasting the externalSkills submodule across opencode/claude-code/pi.
{ lib }:
let
  inherit (lib)
    mkOption
    mkEnableOption
    types
    literalExpression
    ;
in
{
  # Common agent inputs options used by all agent modules
  mkAgentsInputOption =
    description:
    mkOption {
      type = types.nullOr types.anything;
      default = null;
      inherit description;
    };

  # Common  modelOverrides option
  /*
    Allow us to override the current chosen model
    with something else
  */
  mkModelOverridesOption = mkOption {
    type = types.attrsOf types.str;
    default = {

    };
    description = ''
      Agent model overrides. Maps agent slug to model string in config
      Example: { arkadia = "opencode-go/deepseek-v4";} '';
    example = literalExpression ''
      {
      ag-arkadia = "opencode-go/deepseek-v4";
      ag-trikru = opencode-go/deepseek-pro";
      }
    '';
  };
}
