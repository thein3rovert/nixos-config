{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Define options schema - mkEnableOption creates a boolean option with default false
  options.homeSetup.shell = {
    enable = lib.mkEnableOption "Shell configuration with ZSH and Powerlevel10k";
  };

  config = lib.mkIf config.homeSetup.shell.enable {
    # Home Manager ZSH configuration
    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      initExtra = ''
        # Source Powerlevel10k theme
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true

        # Custom key bindings
        bindkey '^w' forward-word
        bindkey '^b' backward-kill-word
        bindkey '^f' autosuggest-accept
      '';
    };

    # Install zsh-powerlevel10k in user packages
    home.packages = with pkgs; [
      zsh-powerlevel10k
    ];
  };
}
