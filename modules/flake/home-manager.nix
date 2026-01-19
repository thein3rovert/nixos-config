_: {
  flake = {
    homeManagerModules = {
      thein3rovert = import ../../homes/thein3rovert;
      # thein3rovert-cloud = ../home/thein3rovert-cloud;
      default = ../home;
    };
  };
}
