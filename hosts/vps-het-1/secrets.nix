{
  age = {
    identityPaths = [ "/home/thein3rovert/.ssh/id_ed25519" ]; # isn't set automatically for some reason
    secrets = {
      linkding = {
        file = ../../secrets/linkding-env.age;
        owner = "thein3rovert";
        # group = "thein3rovert";
        # mode = "0440";
        # path = "/home/thein3rovert/.secret1"; # Path where the drcrypted file is stored
      };
      freshrss = {
        file = ../../secrets/freshrss-env.age;
        owner = "thein3rovert";
        path = "/home/thein3rovert/secrets/.freshrss-env";
      };
    };
  };
}
