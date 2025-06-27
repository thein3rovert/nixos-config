{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    # bat
    # starship
    # docker
    # htop
    # btop
  ];

  # programs.starship = {
  #   enable = true;
  #   # Configuration written to ~/.config/starship.toml
  #   settings = {
  #     add_newline = false;
  #
  #     character.disabled = false; # this is a default but it's to be explicit
  #
  #     cmd_duration = {
  #       min_time = 2000;
  #     };
  #
  #     git_branch.symbol = "🍣 ";
  #
  #     hostname.disabled = false;
  #   };
  # };

  programs.zsh = {
    enable = true;
    # autocd = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    interactiveShellInit = ''
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
      bindkey '^w' forward-word
      bindkey '^b' backward-kill-word
      bindkey '^f' autosuggest-accept

      export NIX_PATH="nixpkgs=channel:nixos-unstable"
      export NIX_LOG="info"
      export TERM="xterm-256color"
      export TERMINAL="kitty"

    '';
  };
}
