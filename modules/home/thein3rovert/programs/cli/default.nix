{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.thein3rovert.programs.cli.enable = lib.mkEnableOption "CLI packages";

  config =
    lib.mkIf (config.homeSetup.thein3rovert.programs.cli.enable)

      {

        programs.zoxide = {
          enable = true;
          enableZshIntegration = true;
        };

        programs.eza = {
          enable = true;
          enableZshIntegration = true;
          enableBashIntegration = true;
          extraOptions = [
            "-l"
            "--icons"
            "--git"
            "-a"
          ];
        };

        programs.bat = {
          enable = true;
        };

        programs.fzf = {
          enable = true;
          enableZshIntegration = true;

          colors = {
            "fg" = "#ebdbb2";
            "bg" = "#3c3836";
            "hl" = "#458588";
            "fg+" = "#ebdbb2";
            "bg+" = "#504945";
            "hl+" = "#8ec07c";
            "info" = "#d79921";
            "prompt" = "#fabd2f";
            "pointer" = "#fe8019";
            "marker" = "#fe8019";
            "spinner" = "#d79921";
            "header" = "#b8bb26";
          };

          defaultOptions = [
            "--preview='bat --color=always -n {}'"
            "--bind 'ctrl-/:toggle-preview'"
            "--header 'Press CTRL-Y to copy command into clipboard'"
            "--bind 'ctrl-/:toggle-preview'"
            "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
          ];
          defaultCommand = "fd --type f --exclude .git --follow --hidden";
          changeDirWidgetCommand = "fd --type d --exclude .git --follow --hidden";
        };

        programs = {
          direnv = {
            enable = true;
            nix-direnv.enable = true;
          };
        };

        home.packages = with pkgs; [
          # Core Utilities
          coreutils # Basic file, shell, and text manipulation utilities
          fd # Fast and user-friendly alternative to `find`
          htop # Interactive process viewer
          lsof # List open files
          tree # Display directories as trees
          zip # Compression utility
          unzip # Decompression utility
          lazygit

          # Networking and HTTP Tools
          httpie # Command-line HTTP client

          # Text Processing
          jq # Command-line JSON processor
          rclone
          ripgrep # Fast search tool like `grep`
          tldr # Simplified and community-driven man pages

          # Shell and Prompt Customization
          oh-my-posh # Prompt theme engine for any shell

          # System Information
          fastfetch # Neofetch-like tool for system information

          # Desktop Utilities
          swww # Wallpaper setter (move to desktop folder)
          pomodoro-gtk # Pomodoro timer with GTK interface

          # Neovim and Development Tools
          lua-language-server # Language server for Lua
          lua51Packages.lua # Lua 5.1 interpreter
          gccgo14 # Go compiler (GCC-based)
          luajitPackages.luarocks # Lua package manager
          tree-sitter # Parser generator tool and library
          vimPlugins.luasnip # Snippet engine for Neovim
          python312Packages.pip # Python package manager
          prettierd # Prettier daemon for formatting
          luajitPackages.jsregexp # JavaScript regular expressions for LuaJIT
          nil # Neovim LSP configuration tool
          # nixfmt-rfc-style now nixfmt
          nixfmt
          checkstyle # Linter
          python3
          # kanata
          # Rust Development
          cargo # Rust package manager and build tool

          # Node.js
          nodejs_24

          #Clipboard
          wl-clipboard
          xclip
          tmux

          # Keybind dependencies
          yad

          # Fuzzy Find
          television

          just
        ];

      };
}
