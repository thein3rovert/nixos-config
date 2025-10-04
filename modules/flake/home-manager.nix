_: {
  flake = {
    homeManagerModules = {
      thein3rovert = ../home/thein3rovert;
      thein3rovert-cloud = ../home/thein3rovert-cloud;
      default = ../home;
    };
  };
}
