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
      n8n = {
        file = "${self.inputs.secrets}/n8n/n8n.age";
      };

      minio = {
        file = "${self.inputs.secrets}/minioS3/minioS3.age";
        path = "/home/thein3rovert/.secrets/minioS3";
      };

      minio_secret = {
        file = "${self.inputs.secrets}/minioS3/minioS3_secret.age";

        path = "/home/thein3rovert/.secrets/minio_secret";
        owner = "thein3rovert";
        mode = "400";
      };

      minio_id = {
        file = "${self.inputs.secrets}/minioS3/minioS3_id.age";
        path = "/home/thein3rovert/.secrets/minio_id";
        owner = "thein3rovert";
        mode = "400";
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
        # old: file = "${self.inputs.secrets}/aws/accessKey/thein3rovert.age";
        owner = "thein3rovert";
        mode = "400";
      };

      garage_thein3rovert_secret = {
        # old: file = "${self.inputs.secrets}/aws/accessSecret/thein3rovert_secret.age";
        file = "${self.inputs.secrets}/minio-client/accessSecret/iv3-garage-secret.age";
        path = "/home/thein3rovert/.secrets/thein3rovert_s3_secret";
        owner = "thein3rovert";
        mode = "400";
      };

      proxmox_api_secrets = {
        file = "${self.inputs.secrets}/proxmox/proxmox_api_secrets.age";
        path = "/home/thein3rovert/.secrets/proxmox_api_secrets";
        owner = "thein3rovert";
        # mode = "400";
      };
    };
  };
}
