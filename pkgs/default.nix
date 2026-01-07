{ pkgs, ... }:
{
  # Define your custom packages here
  #  my-package = pkgs.callPackage ./my-package {};
  github-copilot-cli = pkgs.callPackage ./github-copilot-cli {};
}
