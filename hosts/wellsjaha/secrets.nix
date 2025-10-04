{ self, ... }:
{
  age = {
    identityPaths = [
      # INFO: ABSOLUTE PATH
      "/home/thein3rovert/.ssh/thein3rovert_wellsjaha"
    ];
    secrets = {
      # tailscale = {
      #   file = ../../secrets/tailscale-env-01.age;
      #   owner = "thein3rovert";
      #   path = "/home/thein3rovert/secrets/.tailscale-env";
      # };

      # audiobookshelf = {
      #   file = ../../secrets/audiobookshelf-env.age;
      #   # owner = "thein3rovert";
      #   path = "/home/thein3rovert/secrets/.audiobookshelf-env";
      # };
      linkding = {
        file = "${self.inputs.secrets}/linkding/linkding.age";
        # owner = "thein3rovert";
        path = "/home/thein3rovert/.secrets/.linkding";
      };
    };
  };
}
