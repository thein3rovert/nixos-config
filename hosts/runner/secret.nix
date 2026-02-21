{ self, ... }:
{
  age = {
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_runner"
    ];
    secrets = {
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/runner/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
      };
    };
  };
}
