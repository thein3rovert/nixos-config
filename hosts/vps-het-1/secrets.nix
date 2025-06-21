{
  age = {
    secrets = {
      linkding = {
        file = ../secrets/linkding-env.age;
        owner = "thein3rovert-cloud";
        # group = "thein3rovert";
        # mode = "0440";
        # path = "/home/thein3rovert/.secret1"; # Path where the drcrypted file is stored
      };
      freshrss = {
        file = ../secrets/freshrss-env.age;
        owner = "thein3rovert";
        path = "/home/thein3rovert/secrets/.freshrss-env";
      };
    };
  };
}
