{ self, ... }:
{
  age = {
    identityPaths = [
      # INFO: ABSOLUTE PATH
      "/home/thein3rovert/.ssh/thein3rovert_wellsjaha"
    ];
    secrets = {
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
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
        # owner = "thein3rovert";
      };
    };
  };
}
