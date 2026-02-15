# Simple module using Arkadia library
{
  config,
  pkgs,
  lib,
  arkadia-lib,
  ...
}:

let
  # Example: Using Arkadia to get files (if we had config files)
  # configFiles = arkadia-lib.arkadia.fs.get-files ./configs;

  # Example: Using Arkadia to merge configs
  # mergedConfig = arkadia-lib.arkadia.attrs.merge-deep [ baseConfig extraConfig ];
in
{
  # Install basic tools
  environment.systemPackages = with pkgs; [
    cowsay
    jq
  ];

  # You can also use Arkadia functions for more complex logic
  # For example, conditionally enable based on files present
  # programs.zsh.enable = builtins.pathExists (arkadia-lib.arkadia.fs.get-arkadia-file "use-zsh");
}
