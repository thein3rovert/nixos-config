{
  config,
  lib,
  ...
}:
{

  options.homeSetup.thein3rovert.programs.git.enable = lib.mkEnableOption "git VS";
  config = lib.mkIf config.homeSetup.thein3rovert.programs.git.enable {
    programs = {
      git = {
        enable = true;
        delta.enable = true; # prietter diffs

        # Git lfs stores large files outside
        # of git history in other to keep repo
        # small
        lfs.enable = true; # better handling of big files

        userName = "thein3rovert";
        userEmail = "danielolaibi@gmail.com";

        extraConfig = {
          color.ui = true;
          github.user = "thein3rovert";
          push.autoSetupRemote = true;
        };
      };
    };
  };
}
