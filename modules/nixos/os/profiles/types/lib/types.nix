# ==============================
#       Type Aliases Library
# ==============================
# This module provides convenient aliases for commonly used Nix types
# and functions to reduce verbosity in module definitions.
{lib}:
with lib; {
  # ==============================
  #      Option Functions
  # ==============================
  createOption = mkOption;
  createEnableOption = mkEnableOption;
  If = mkIf;
  mapAttribute = mapAttrs;

  # ==============================
  #         Type Aliases
  # ==============================
  attributeSetOf = types.attrsOf;
  subModule = types.submodule;
  string = types.str;
  list = types.listOf;
  boolean = types.bool;
  port = types.port;
  integer = types.int;

  # ==============================
  #    Additional Common Types
  # ==============================
  package = types.package;
  path = types.path;
  lines = types.lines;
  enum = types.enum;
  nullOr = types.nullOr;
  oneOf = types.oneOf;
  either = types.either;
  unspecified = types.unspecified;
  raw = types.raw;

  # ==============================
  #      Composite Types
  # ==============================
  listOfStrings = types.listOf types.str;
  listOfPackages = types.listOf types.package;
  attributeSetOfStrings = types.attrsOf types.str;
  attributeSetOfPackages = types.attrsOf types.package;
}
