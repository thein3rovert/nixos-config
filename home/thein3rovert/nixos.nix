{ config, ... }: { imports = [ ./home.nix ../common ../features/cli ]; 

features = {
  cli = {
    zsh.enable = true;
  };
};

}
