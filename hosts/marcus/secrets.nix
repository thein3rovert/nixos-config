{ self, ... }:
{
  age = {
    # ------------------------------
    # TEXT SECRETS
    # -------------------------------
    identityPaths = [
      "/home/thein3rovert/.ssh/thein3rovert_marcus"
    ];
    secrets = {

      # ------------------------------
      # SERVICE SECRETS
      # -------------------------------
      tailscale = {
        file = "${self.inputs.secrets}/tailscale/shared/tailscale-auth.age";
        path = "/home/thein3rovert/.secrets/tailscale-auth";
      };
      kestra-password = {
        file = "${self.inputs.secrets}/kestra/kestra.age";
        path = "/home/thein3rovert/.secrets/kestra-password";
      };
    };
  };
}
