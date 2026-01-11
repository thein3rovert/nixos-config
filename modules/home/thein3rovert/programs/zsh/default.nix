{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.zsh.enable =
    lib.mkEnableOption "Zsh for main user thein3rovert";

  config =
    lib.mkIf (config.homeSetup.thein3rovert.programs.zsh.enable)
      # TODO: Make the hsotname a list just in case instead of one hostname
      {

        programs.zsh = {
          enable = true;
          enableCompletion = true;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          oh-my-zsh = {
            enable = true;
            plugins = [
              "docker-compose"
              "docker"
            ];
            theme = "dst";
          };
          initContent = ''

            # Check if the current TTY is /dev/tty1 and run Hyprland
            if [[ $(tty) == "/dev/tty1" ]]; then
              exec Hyprland &> /dev/null
            fi


            export NIX_PATH="nixpkgs=channel:nixos-unstable"
            export NIX_LOG="info"
            export TERM="xterm-256color"
            export TERMINAL="kitty"
            export HOSTNAME="nixos"

            bindkey '^f' autosuggest-accept
            # OH-MY-POSH
            # if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
            #   eval "$(oh-my-posh init zsh --config ~/.poshthemes/gruvbox.omp.json )"
            # fi

            export PATH="$HOME/bin:$PATH"

            # Git Commit Message Function
            cmsg() {
                if [ -z "$4" ]; then
                  git commit -m "$1($2): $3"
                else
                  git commit -m "$1($2): $3" -m "$4"
                fi
              }
            gch() {
              scope=$1
              shift
              msg="$*"
              if [ -z "$msg" ]; then
                msg="ongoing homelab adjustments"
              fi
              git commit -m "chore($scope): $msg"
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
            gs = "git status";
            gl = "git log --graph --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%an%C(reset)%C(bold yellow)%d%C(reset) %C(dim white)- %s%C(reset)' --all"; # check medium for better command line approach
            gp = "git push origin";
            gr = "git reset --soft HEAD~1";
            gdiff = "git diff";
            gco = "git checkout";
            gb = "git branch";
            glog = "git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit";
            grf = "git reflog --date=relative";
            gpu = "git pull origin";

            cat = "bat --style=plain";

            # History Search
            h = "history";
            hg = "history | grep ";

            # Editor
            zed = "zeditor"; # Zed editor

            # Aliases: tmux
            tn = "tmux new-session -s";
            tl = "tmux list-sessions";
            ta = "tmux attach-session -t";
            tk = "tmux kill-session -t";

            # Nix
            nix-test = "nix-instantiate --eval --strict -A";
            # Clan deplomeny
            clan-rebuild-switch = "clan machines update";
            cl = "clan machines list";

          };
        };

      };
}
