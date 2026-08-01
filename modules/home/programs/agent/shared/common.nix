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
    default = { };
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

  # External SKill submodules - use by opencode, claude-code and pi modulkes
  agentExternalSkillOption = mkOption {
    type = types.listOf (
      types.submodule {
        options = {
          # submodules = src -> dir (containing the skills)
          src = mkOption {
            type = types.anything;
            description = "Flake input pointing to a skills repository root.";
          };
          agentSkillsDir = mkOption {
            type = types.str;
            default = "skills";
            description = "Subdirectory inside src that contains skills folder";
          };
          selectAgentSkills = mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            description = "List of skills names to pick from the provided sources
          null means include everything found in the skill dir";
          };
        };
      }
    );
    # Default values for this submodules
    default = [ ];
    description = ''
      External skills sources to be passed to mkSkills function
      Each ent ry maps directly to an element of an external skills list
      accepted by the AGENTS flake's lib.mkSkills'';
    example = literalExpression ''
      [
        {src = inputs.skills-quick-chat; selectSkills = [ "quick-chat"]; }
        {src = inputs.obsidian; }
      ]
    '';
  };

  # Helper to map ExternalSkills from module to mkSKills format
  mapExternalSkills =
    cfgEntries:
    map (
      entry:
      {
        inherit (entry) src agentSkillsDir;
      }
      # If selected agent skills is not null then pass into entry -> src and selected agent skills
      // lib.optionalAttrs (entry.selectAgentSkills != null) { inherit (entry) selectAgentSkills; }
    ) cfgEntries;
}
