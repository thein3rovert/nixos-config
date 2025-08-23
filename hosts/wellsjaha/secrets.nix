{
  age = {
    secrets = {
      tailscale = {
        file = ../../secrets/tailscale-env-01.age;
        owner = "thein3rovert";
        path = "/home/thein3rovert/secrets/.tailscale-env";
      };
      audiobookshelf = {
        file = ../../secrets/audiobookshelf-env.age;
        # owner = "thein3rovert";
        path = "/home/thein3rovert/secrets/.audiobookshelf-env";
      };
    };
  };
}
