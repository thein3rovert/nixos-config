{ config, lib, ... }:
with lib;
let
  cfg = config.features.cli.zsh;
in
{
  options.features.cli.zsh.enable = mkEnableOption "enable extended zsh configuration";

  config = mkIf cfg.enable {
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
      initExtra = ''
                      bindkey '^f' autosuggest-accept
                      # OH-MY-POSH
                      if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
                        eval "$(oh-my-posh init zsh --config ~/.poshthemes/gruvbox.omp.json )"
                      fi

                      export NIX_PATH="nixpkgs=channel:nixos-unstable"
                      export NIX_LOG="info"
                      export TERMINAL="kitty"

                      export PATH="$HOME/bin:$PATH"

                      # Check if the current TTY is /dev/tty1 and run Hyprland
                      if [[ $(tty) == "/dev/tty1" ]]; then
                        exec Hyprland &> /dev/null
                      fi

                       # Git Commit Message Function
                cmsg() {
                  if [ -z "$4" ]; then
                    git commit -m "$1($2): $3"
                  else
                    git commit -m "$1($2): $3" -m "$4"
                  fi
                }

          cmsg-new() {
          # Simple parameters
          local TYPE=$1
          local SCOPE=$2
          local SHORT_MSG=$3
          local LONG_MSG=$4
          
          # Simple validation of parameters
          if [[ -z "$TYPE" || -z "$SCOPE" || -z "$SHORT_MSG" ]]; then
            echo "Usage: cmsg <type> <scope> <short_message> [<long_message>]"
            echo "Example: cmsg fix auth 'prevent race condition' 'Problem: Multiple auth requests caused token issues'"
            return 1
          fi
          
          # Build the commit message to validate
          local FULL_MSG="$TYPE($SCOPE): $SHORT_MSG"
          
          # Validate against conventional commits format
          if ! echo "$FULL_MSG" | grep -q -E "^(feat|fix|docs|style|refactor|perf|test|chore|build|ci|revert)(\(.+\))?: .+"; then
            echo "Error: Commit message must follow conventional commits format."
            echo "Expected format: type(scope): description"
            echo "Allowed types: feat, fix, docs, style, refactor, perf, test, chore, build, ci, revert"
            return 1
          fi
          
          # Create commit with appropriate message format
          if [ -z "$LONG_MSG" ]; then
            git commit -m "$FULL_MSG"
          else
            git commit -m "$FULL_MSG" -m "$LONG_MSG"
          fi
        }
      '';
      shellAliases = {
        # Dirs
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        "....." = "cd ../../../..";
        "......" = "cd ../../../../..";

        # Eza
        ltree = "eza -l --icons --git -a";
        l = "eza --tree --level=2 --icons --git"; # Previous Command - ltree
        lt = "eza --tree --level=2 --long --icons --git";
        ls = "eza";

        # Processes and Memory
        grep = "rg";
        ps = "procs";

        # Git
        ga = "git add";
        gc = "git commit -m";
        #gc = "cmsg"; # The contains "git commit -m"
        gs = "git status";
        gl = "git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"; # check medium for better command line approach
        gp = "git push origin";
        gr = "git reset --soft HEAD~1";
        gdiff = "git diff";
        gco = "git checkout";
        gb = "git branch";
        glog = "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit";
        gpu = "git pull origin";

        cat = "bat";

        # History Search
        h = "history";
        hg = "history | grep ";

        # Editor
        zed = "zeditor"; # Zed editor

      };
    };

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
