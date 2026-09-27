{
  config,
  lib,
  ...
}:
{
  options.homeSetup.programs.fzf.enable = lib.mkEnableOption "Eza systtem config";

  config = lib.mkIf config.homeSetup.programs.fzf.enable {

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    # Tokyo Night - ported from .config preview.
    # NOTE: home-manager's fzf module ships gruvbox-themed FZF_DEFAULT_OPTS
    # by default, so we mkForce a merged value: keep its bat preview + copy
    # binds, swap gruvbox colors for Tokyo Night.
    home.sessionVariables.FZF_DEFAULT_OPTS = lib.mkForce "--preview='bat --color=always -n {}' --bind 'ctrl-/:toggle-preview' --header 'Press CTRL-Y to copy command into clipboard' --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort' --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a --color=border:#292e42,label:#c0caf5,query:#c0caf5";
  };
}
