{ self, ... }:
{
  age = {
    # ------------------------------
    # TEXT SECRETS
    # -------------------------------
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_bellamy"
    ];
    secrets = {
      godaddy = {
        file = "${self.inputs.secrets}/godaddy/godaddy.age";
        path = "/home/thein3rovert/.secrets/.traefik-godaddy";
      };
      freshrss = {
        file = "${self.inputs.secrets}/freshrss/freshrss.age";
        path = "/home/thein3rovert/.secrets/.freshrss";
      };
      linkding = {
        file = "${self.inputs.secrets}/linkding/linkding.age";
        path = "/home/thein3rovert/.secrets/.linkding";
      };
      glance = {
        file = "${self.inputs.secrets}/glance/glance.age";
      };
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
        # owner = "thein3rovert";
      };
    };
  };
}
