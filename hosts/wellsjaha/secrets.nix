{ self, ... }:
{
  age = {
    identityPaths = [
      # "/etc/ssh/ssh_host_ed25519_key"
      "/home/thein3rovert/.ssh/thein3rovert_wellsjaha"
    ]; # isn't set automatically for some reason
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
