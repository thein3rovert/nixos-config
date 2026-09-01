{ pkgs, ... }:
{
  programs = {
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home.packages = with pkgs; [
    #   insomnia
    #   hugo
    #   pandoc
    postman
    jdk # Java dev kit
    jdt-language-server # Jdtls integration
    checkstyle # Linter
    google-java-format # Formatter
    maven # Build automation tool for java
    nixfmt-rfc-style
    python3
    kanata
  ];
}
