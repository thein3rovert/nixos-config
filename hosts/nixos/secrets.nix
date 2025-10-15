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

      freshrss = {
        file = "${self.inputs.secrets}/freshrss/freshrss.age";
        path = "/home/thein3rovert/.secrets/.freshrss";
      };
      # mode = "0440";
      # path = "/home/thein3rovert/.secret1"; # Path where the drcrypted file is stored

      # ------------------------------
      # SERVICE SECRETS
      # -------------------------------

      # minio = {
      #   file = ../../secrets/minio-env.age;
      #   owner = "thein3rovert";
      #   path = "/home/thein3rovert/secrets/.minio-env";
      # };
      # tailscale = {
      #   file = ../../secrets/tailscale-env.age;
      #   owner = "thein3rovert";
      #   path = "/home/thein3rovert/secrets/.tailscale-env";
      # };
    };
  };
}
