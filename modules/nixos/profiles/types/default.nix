# ==============================
#       Types Profile Module
# ==============================
# This module provides convenient type aliases for use throughout
# the NixOS configuration when enabled.
{
  config,
  lib,
  ...
}: {
  # ==============================
  #         Module Options
  # ==============================
  options.nixosSetup.profiles.types.enable = lib.mkEnableOption "Type aliases for cleaner module definitions";

  config = lib.mkIf config.nixosSetup.profiles.types.enable {
    # When enabled, the type aliases become available through lib.t
    # in any module that imports this configuration.
    #
    # Usage example:
    # options.foo = lib.t.createOption {
    #   type = lib.t.string;
    #   default = "bar";
    # };
  };
}
