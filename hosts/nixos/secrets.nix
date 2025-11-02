{ self, ... }:
{
  age = {
    # ------------------------------
    # TEXT SECRETS
    # -------------------------------
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_nixos"
    ];
    secrets = {

      # ------------------------------
      # SERVICE SECRETS
      # -------------------------------

      freshrss = {
        file = "${self.inputs.secrets}/freshrss/freshrss.age";
        path = "/home/thein3rovert/.secrets/.freshrss";
      };

      tailscale = {
        file = "${self.inputs.secrets}/tailscale/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
        # owner = "thein3rovert";
      };

      glance = {
        file = "${self.inputs.secrets}/glance/glance.age";
      };
      # minio = {
      #   file = ../../secrets/minio-env.age;
      #   owner = "thein3rovert";
      #   path = "/home/thein3rovert/secrets/.minio-env";
      # };

    };
  };
}
