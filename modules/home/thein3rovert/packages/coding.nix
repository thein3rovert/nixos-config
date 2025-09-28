{
  config,
  lib,
  pkgs,
  ...
}:
with lib; # So we can make use of the functions and attributes with in lib modules
let # `let` lets us define a local variable
  cfg = config.homeSetup.thein3rovert.packages.coding;
in
{
  options.homeSetup.thein3rovert.packages.coding.enable =
    lib.mkEnableOption "thein3rovert coding packages";

  # ------------------------------------
  # Insteaed of using:
  # config = lib.mkIf config.homeSetup.thein3rovert.packages.coding.enable
  # we can replace with the variable
  # ------------------------------------

  config = lib.mkIf cfg.enable {

    home.packages = with pkgs; [
      postman
      jdk # Java dev kit
      jdt-language-server # Jdtls integration
      checkstyle # Linter
      google-java-format # Formatter
      maven # Build automation tool for java
      nixfmt-rfc-style
      python3
      # kanata
      jetbrains.idea-ultimate
      vscode
    ];
  };
}
