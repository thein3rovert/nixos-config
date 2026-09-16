{ self, ... }:
{
  age = {
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_zeke"
    ];
    secrets = {
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/shared/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
      };
      technitium-env = {
        file = "${self.inputs.secrets}/technitium/technitium-env.age";
        path = "/home/thein3rovert/.secrets/.technitium-env";
      };
    };
  };
}
