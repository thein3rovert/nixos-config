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
        theme = "opencode";
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
  };
}
