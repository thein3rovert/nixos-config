_: {
  flake = {
    homeManagerModules = {
      thein3rovert = ./homes/thein3rovert;
      thein3rovert-cloud = ./home/thein3rovert-cloud;
      default = ./modules/home;
    };
  };
}
