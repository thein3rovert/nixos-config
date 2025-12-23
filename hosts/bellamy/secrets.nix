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
      minio = {
        file = "${self.inputs.secrets}/minioS3/minioS3.age";
      };
      rpcSecret = {
        file = "${self.inputs.secrets}/garage/rpc_secret.age";
      };

      adminToken = {
        file = "${self.inputs.secrets}/garage/admin_token.age";
      };
      garage-env = {
        file = "${self.inputs.secrets}/garage/garage-env.age";
        path = "/home/thein3rovert/.secrets/.garage-env";
        owner = "thein3rovert";
        group = "users";
        mode = "0400";
      };

      garage_thein3rovert_id = {
              file = "${self.inputs.secrets}/minio-client/accessKey/iv3-garage-id.age";
              path = "/home/thein3rovert/.secrets/thein3rovert_s3_id";
              owner = "thein3rovert";
              mode = "400";
            };

            garage_thein3rovert_secret = {
              file = "${self.inputs.secrets}/minio-client/accessSecret/iv3-garage-secret.age";
              path = "/home/thein3rovert/.secrets/thein3rovert_s3_secret";
              owner = "thein3rovert";
              mode = "400";
            };
    };
  };
}
