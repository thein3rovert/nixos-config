{
  age = {
    # ------------------------------
    # TEXT SECRETS
    # -------------------------------

    secrets = {
      secret1 = {
        file = ../../secrets/secret1.age;
        owner = "thein3rovert";
        # group = "thein3rovert";
        # mode = "0440";
        # path = "/home/thein3rovert/.secret1"; # Path where the drcrypted file is stored
      };
      secret2 = {
        file = ../../secrets/secret2.age;
        owner = "thein3rovert";
        # group = "thein3rovert";
        # mode = "0440";
        # path = "/home/thein3rovert/.secret1"; # Path where the drcrypted file is stored
      };

      # ------------------------------
      # SERVICE SECRETS
      # -------------------------------

      minio = {
        file = ../../secrets/minio-env.age;
        owner = "thein3rovert";
        path = "/home/thein3rovert/secrets/.minio-env";
      };
      tailscale = {
        file = ../../secrets/tailscale-env.age;
        owner = "thein3rovert";
        path = "/home/thein3rovert/secrets/.tailscale-env";
      };
    };
  };
}
