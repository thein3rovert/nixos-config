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
        # delta.enable = true; # prettier diffs
        # Git lfs stores large files outside
        # of git history in other to keep repo
        # small
        lfs.enable = true; # better handling of big files
        userName = "thein3rovert";
        userEmail = "danielolaibi@gmail.com";
        extraConfig = {
          column.ui = "auto";

          branch.sort = "-committerdate";

          init.defaultBranch = "main";

          diff = {
            algorithm = "histogram";
            colorMoved = "plain";
            mnemonicPrefix = true;
            renames = true;
            context = 3;
            interHunkContext = 10;
          };

          delta = {
            navigate = true;
            light = false;
            side-by-side = true;
          };

          status = {
            branch = true;
            showStash = true;
            showUntrackedFiles = "all";
          };

          interactive.diffFilter = "delta --color-only --dark --true-color always";

          push = {
            default = "simple";
            autoSetupRemote = true;
            followTags = true;
          };

          pull.rebase = true;

          rebase = {
            autoStash = true;
            missingCommitsCheck = "warn";
          };

          fetch = {
            prune = true;
            pruneTags = true;
            all = true;
          };

          help.autocorrect = "prompt";

          commit = {
            gpgsign = false;
            verbose = true;
          };

          core.excludesfile = "~/.gitignore";

          tag.gpgsign = false;

          log = {
            abbrevCommit = true;
            graphColors = "blue,yellow,cyan,magenta,green,red";
          };

          color = {
            ui = true;
            diff = {
              meta = "black bold";
              frag = "magenta";
              context = "white";
              whitespace = "yellow reverse";
              old = "red";
            };
            decorate = {
              HEAD = "red";
              branch = "blue";
              tag = "yellow";
              remoteBranch = "magenta";
            };
            branch = {
              current = "magenta";
              local = "default";
              remote = "yellow";
              upstream = "green";
              plain = "blue";
            };
          };

          github.user = "thein3rovert";
        };
      };
    };
  };
}
