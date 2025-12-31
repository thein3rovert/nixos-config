{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkEnableOption
    mkIf
    ;
  If = mkIf;
  createEnableOption = mkEnableOption;
  cfg = config.nixosSetup.profiles.shell;
in {
  options.nixosSetup.profiles.shell.enable = createEnableOption "Shared Shell Config";
  config = If cfg.enable {
    programs.zsh = {
      enable = true;
      autocd = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
        POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
        bindkey '^w' forward-word
        bindkey '^b' backward-kill-word
        bindkey '^f' autosuggest-accept
      '';
    };
  };
}
