{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.zsh.enable =
    lib.mkEnableOption "Zsh for main user thein3rovert";

  config = lib.mkIf config.homeSetup.thein3rovert.programs.zsh.enable {

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      oh-my-zsh = {
        enable = true;
        plugins = [
          "docker-compose"
          "docker"
        ];
        theme = "dst";
      };
      initContent = ''
        export NIX_PATH="nixpkgs=channel:nixos-unstable"
        export NIX_LOG="info"
        export TERM="xterm-256color"
        export TERMINAL="kitty"


      '';
      shellAliases = {
        # Dirs
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";

        cat = "bat";

        # History Search
        h = "history";
        hg = "history | grep ";

      };
    };

  };
}
