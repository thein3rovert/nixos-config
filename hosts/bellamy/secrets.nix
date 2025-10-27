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
    };
  };
}
