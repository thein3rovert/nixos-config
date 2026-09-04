{ self, ... }:
{
  age = {
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_roan"
    ];
    secrets = {
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/shared/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
      };
    };
  };
}
