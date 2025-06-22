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
    enableCompletion = true;
    autosuggestions.enable = true;

    # for some reason these are flipped
    interactiveShellInit = ''
      bindkey '^[[Z'   complete-word       # tab          | complete
      bindkey '^I'     autosuggest-accept  # shift + tab  | autosuggest
    '';

    initContent = ''
       bindkey '^f' autosuggest-accept
       # # OH-MY-POSH
       # if [ "$TERM_PROGRAM" != "Apple_Terminal" ]; then
       #   eval "$(oh-my-posh init zsh --config ~/.poshthemes/gruvbox.omp.json )"
       # fi

       export NIX_PATH="nixpkgs=channel:nixos-unstable"
       export NIX_LOG="info"
      export TERMINAL="xterm-256color"        
    '';

  };
}
