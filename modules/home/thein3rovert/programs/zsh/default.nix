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
            # export TERM="tmux-256color"
            export TERMINAL="kitty"
            export HOSTNAME="nixos"
            export EDITOR="nvim"
            export VISUAL="nvim"

            bindkey '^f' autosuggest-accept
            # OH-MY-POSH
            # if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
            #   eval "$(oh-my-posh init zsh --config ~/.poshthemes/gruvbox.omp.json )"
            # fi

            export PATH="$HOME/bin:$PATH"
            export PATH="$HOME/.npm-global/bin:$PATH"

            gch() {
              msg="$*"
              if [ -z "$msg" ]; then
                msg="ongoing homelab adjustments"
              fi

              git add .
              git commit -m "chore: $msg"
              git push
            }

            gcc() {
              msg="$*"
              if [ -z "$msg" ]; then
                msg="ongoing homelab adjustments"
              fi

              git add .
              git commit -m "chore: $msg"
            }
            # Create directory and cd into it
            mkcd() {
              mkdir -p "$1" && cd "$1"
            }

            tmux() {
              # Create sessions if they don't exist
              if ! command tmux has-session -t default 2>/dev/null; then
                command tmux new-session -d -s default
                command tmux new-session -d -s obsidian
                command tmux new-session -d -s nixos-config
              fi
              # Attach to default session
              command tmux attach -t default
            }

            # Backlog.md quick task creation
            # Usage: btc "Task title" "Optional description"
            btc() {
              if [ -z "$1" ]; then
                echo "Usage: btc \"Task title\" \"Optional description\""
                return 1
              fi
              if [ -n "$2" ]; then
                backlog task create "$1" -d "$2"
              else
                backlog task create "$1"
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

            # GIT
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
            gflog = "git reflog --date=relative";
            gpu = "git pull origin";

            cat = "bat --style=plain";
            zed = "zeditor";

            # History Search
            h = "history";
            hg = "history | grep ";

            # TMUX
            # tmux = "tmux new-session -A -s default";

            # NIX
            nix-test = "nix-instantiate --eval --strict -A";

            # DEPLOYMENT
            clan-rebuild-switch = "clan machines update";
            cl = "clan machines list";
            proxmox-env = "source ~/Documents/project/scripts/terraform/proxmox/proxmox_vault_env.sh";

            # deploy-rs — push home-manager to non-NixOS hosts from this workstation
            # Usage: deploy-trikru   (builds here, copies closure, activates on trikru)
            deploy-trikru = "nix run github:serokell/deploy-rs -- --skip-checks .#trikru.home -- --accept-flake-config";

            # SYSTEMD
            sc-status = "systemctl status";
            sc-restart = "systemctl restart";
            sc-start = "systemctl start";
            sc-stop = "systemctl stop";
            sc-enabled = "systemctl enable";

            jc-follow = "journalctl -f";
            jc-log = "journalctl -u";
            jc-follow-log = "journalctl -fu";

            # QUICK ACCESS
            notes = "cd /home/thein3rovert/Documents/project";
            nvim-config = "cd /home/thein3rovert/.config/nvim";
            project = "cd /home/thein3rovert/Documents/project";
            search-files = "tv files ~/nixos-config";

            k = "kubectl";

            # BACKLOG.MD
            btl = "backlog task list";
            bte = "backlog task edit";
            bb = "backlog board";
            bbr = "backlog browser";
          };
        };

      };
}
