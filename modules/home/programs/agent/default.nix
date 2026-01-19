{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.homeSetup.programs.agent.enable =
    lib.mkEnableOption "Base AI agent for with opencode experiment";

  config = lib.mkIf config.homeSetup.programs.agent.enable {
    home.packages = with pkgs; [
      bun
      (python3.withPackages (
        ps: with ps; [
          pip
        ]
      ))
    ];

    programs.opencode = {
      enable = true;
      settings = {
        theme = "lucent-orng";
        plugin = [ "oh-my-opencode" ];
        formatter = {
          alejandra = {
            command = [
              "alejandra"
              "-q"
              "-"
            ];
            extensions = [ ".nix" ];
          };
        };

        provider = {
          github-copilot = {
            models = {
              "gpt-4.1" = {
                name = "GPT-4.1";
                limit = {
                  context = 128000;
                  output = 16384;
                };
                modalities = {
                  input = [ "text" ];
                  output = [ "text" ];
                };
              };
              "claude-sonnet-4-5" = {
                name = "Claude Sonnet 4.5";
                limit = {
                  context = 128000;
                  output = 16000;
                };
                modalities = {
                  input = [ "text" ];
                  output = [ "text" ];
                };
              };
            };
          };
        };
      };

    };
    home.file.".config/opencode/oh-my-opencode.json".text = builtins.toJSON {
      "$schema" =
        "https://raw.githubusercontent.com/code-yeongyu/oh-my-opencode/master/assets/oh-my-opencode.schema.json";
      google_auth = false;
      agents = {
        Sisyphus = {
          model = "github-copilot/gpt-4.1";
          permission = {
            edit = "allow";
            bash = {
              "*" = "allow";
              "rm *" = "ask";
              "rmdir *" = "ask";
              "mv *" = "ask";
              "chmod *" = "ask";
              "chown *" = "ask";
              "git *" = "ask";
              "git status*" = "allow";
              "git log*" = "allow";
              "git diff*" = "allow";
              "git branch*" = "allow";
              "git show*" = "allow";
              "git stash list*" = "allow";
              "git remote -v" = "allow";
              "git add *" = "allow";
              "git commit *" = "allow";
              "jj *" = "ask";
              "jj status" = "allow";
              "jj log*" = "allow";
              "jj diff*" = "allow";
              "jj show*" = "allow";
              "npm *" = "ask";
              "npx *" = "ask";
              "bun *" = "ask";
              "bunx *" = "ask";
              "uv *" = "ask";
              "pip *" = "ask";
              "pip3 *" = "ask";
              "yarn *" = "ask";
              "pnpm *" = "ask";
              "cargo *" = "ask";
              "go *" = "ask";
              "make *" = "ask";
              "dd *" = "deny";
              "mkfs*" = "deny";
              "fdisk *" = "deny";
              "parted *" = "deny";
              "eval *" = "deny";
              "source *" = "deny";
              "curl *|*sh" = "deny";
              "wget *|*sh" = "deny";
              "sudo *" = "deny";
              "su *" = "deny";
              "systemctl *" = "deny";
              "service *" = "deny";
              "shutdown *" = "deny";
              "reboot*" = "deny";
              "init *" = "deny";
              "> /dev/*" = "deny";
              "cat * > /dev/*" = "deny";
            };
            external_directory = "ask";
            doom_loop = "ask";
          };
        };
      };
      disabled_mcps = [
        "context7"
        "websearch"
      ];
    };
  };
}
