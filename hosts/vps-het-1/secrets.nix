{
  age = {
    identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ]; # isn't set automatically for some reason
    secrets = {
      linkding = {
        file = ../../secrets/linkding-env.age;
        owner = "thein3rovert-cloud";
        # group = "thein3rovert";
        # mode = "0440";
        # path = "/home/thein3rovert/.secret1"; # Path where the drcrypted file is stored
      };
      freshrss = {
        file = ../../secrets/freshrss-env.age;
        owner = "thein3rovert-cloud";
        path = "/home/thein3rovert-cloud/secrets/.freshrss-env";
      };
      traefik = {
        file = ../../secrets/traefik-env.age;
        owner = "traefik";
        path = "/home/thein3rovert-cloud/secrets/.traefik-env";
      };
    };
  };
}
