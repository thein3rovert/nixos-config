{ config, lib, ... }:
{
  options.nixosSetup.services.forgejo = {
    enable = lib.mkEnableOption "Forgejo git forge";

    database = lib.mkOption {
      description = "Database to use either sqlite or postgresql";
      default = "sqlite";
      type = lib.types.str;
    };
  };

  config = lib.mkIf config.nixosSetup.services.forgejo.enable {

    services.forgejo = {
      enable = true;
      database = lib.mkIf (config.nixosSetup.services.forgejo.database == "postgresql") {
        createDatabase = true;
        host = config.homelab.ipAddresses;
        # INFO: Create database user in postgresql config
        name = "forgejo";
        # passwordFile = config.age.secrets.postgres-forgejo.path;
        type = "postgres";
        user = "forgejo";
      };

      lfs.enable = true;
      package = pkgs.forgejo;

      settings = {
        actions = {
          ARTIFACT_RETENTION_DAYS = 15;
          DEFAULT_ACTIONS_URL = "https://github.com";
          ENABLED = true;
        };

        cron = {
          ENABLED = true;
          RUN_AT_START = false;
        };

        DEFAULT.APP_NAME = "Forĝejo";
        federation.ENABLED = true;
        indexer.REPO_INDEXER_ENABLED = true;

        log = {
          ENABLE_SSH_LOG = true;
          LEVEL = "Debug";
        };

        picture = {
          AVATAR_MAX_FILE_SIZE = 5242880;
          ENABLE_FEDERATED_AVATAR = true;
        };

        repository = {
          DEFAULT_BRANCH = "master";
          ENABLE_PUSH_CREATE_ORG = true;
          ENABLE_PUSH_CREATE_USER = true;
          PREFERRED_LICENSES = "GPL-3.0";
        };

        security.PASSWORD_CHECK_PWN = true;

        server = {
          DOMAIN = config.mySnippets.cute-haus.networkMap.forgejo.vHost;
          HTTP_PORT = config.mySnippets.cute-haus.networkMap.forgejo.port;
          LANDING_PAGE = "explore";
          LFS_START_SERVER = true;
          ROOT_URL = "https://${config.mySnippets.cute-haus.networkMap.forgejo.vHost}/";
          SSH_DOMAIN = config.mySnippets.cute-haus.networkMap.forgejo.sshVHost;
          SSH_LISTEN_PORT = 2222;
          SSH_PORT = 2222;
          START_SSH_SERVER = true;
        };

        # service = {
        #   ALLOW_ONLY_INTERNAL_REGISTRATION = true;
        #   DISABLE_REGISTRATION = true;
        #   ENABLE_NOTIFY_MAIL = true;
        # };

        session.COOKIE_SECURE = true;

        # storage = {
        #   STORAGE_TYPE = "minio";
        #   MINIO_ENDPOINT = "s3.us-east-005.backblazeb2.com";
        #   MINIO_BUCKET_LOOKUP = "dns";
        #   MINIO_BUCKET = "aly-forgejo";
        #   MINIO_LOCATION = "us-east-005";
        #   MINIO_USE_SSL = true;
        #   MINIO_CHECKSUM_ALGORITHM = "md5";
        # };

        ui.DEFAULT_THEME = "forgejo-auto";

        "ui.meta" = {
          AUTHOR = "Aly Raffauf";
          DESCRIPTION = "Self-hosted git forge for projects + toys.";
          KEYWORDS = "git,source code,forge,forĝejo,aly raffauf";
        };
      };
    };

  };
}
