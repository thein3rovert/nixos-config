{
  imports = [
    # ../common # INFO: Dont want home-manager for now
    ./services
    ./configuration.nix
    ./shell.nix # INFO: TEMPORARY WHILE I CLEAN UP
    # ./secrets.nix
  ];
}
