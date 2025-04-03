{ config, ... }: { imports = [ ./home.nix ../common ../features/cli ../features/coding ../features/desktop];

features = {
  cli = {
    zsh.enable = true;
  };
};

}
