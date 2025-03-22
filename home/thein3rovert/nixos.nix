{ config, ... }: { imports = [ ./home.nix ../common ../features/cli ../features/coding];

features = {
  cli = {
    zsh.enable = true;
  };
};

}
