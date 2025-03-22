{pkgs, ...}: {
  imports = [
#  ./emacs.nix
 #  ./golang.nix
#  ./nix.nix
 #  ./nodejs.nix
#    ./rust.nix
     ./tools.nix
     ./editor.nix
  ];

  home.packages = with pkgs; [
  ];
}
