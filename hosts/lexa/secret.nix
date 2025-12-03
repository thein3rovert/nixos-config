{ self, ... }:
{
  age = {
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_lexa"
    ];
    secrets = {
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
      };
    };
  };
}
