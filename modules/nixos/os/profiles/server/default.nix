{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkDefault
    mkIf
    ;
  If = mkIf;
  setDefault = mkDefault;
  createEnableOption = mkEnableOption;
  cfg = config.nixosSetup.profiles.server;
in
{
  options.nixosSetup.profiles.server.enable = createEnableOption "Server Optimization";
  config = If cfg.enable {

    # ================================================================
    # Kernel Parameter Tuning
    # Optimize file system limits for server workloads with many connections
    #
    # /*
    # - fs.file-max: Maximum file handles (increased to ~2M from default ~65k)
    # - inotify.max_user_instances: Max inotify instances per user (8192)
    # - inotify.max_user_watches: Max watchable files per user (524288)
    # */
    # ================================================================
    boot.kernel.sysctl = {
      # Improved file monitoring
      "fs.file-max" = lib.mkDefault 2097152;
      "fs.inotify.max_user_instances" = lib.mkOverride 100 8192;
      "fs.inotify.max_user_watches" = lib.mkOverride 100 524288;
    };

    # ================================================================
    # Documentation Settings
    # Disable documentation to save disk space and reduce closure size
    # ================================================================
    documentation = {
      enable = false;
      nixos.enable = false;
    };

    # ================================================================
    # System Services
    # Configure essential server services for performance and reliability
    #
    # /*
    # - bpftune: Auto-tunes kernel parameters based on workload, when
    # siabled it used `static tuning`
    # - journald: Volatile storage (RAM only), 32MB limit to reduce disk I/O
    # - timesyncd: Keeps server clock accurate for logs and certificates
    # */
    # ================================================================
    services = {
      bpftune.enable = false;
      # Minimal logging - 8MB is plenty for minimal needs
      journald = {
        storage = "volatile";
        # extraConfig = "SystemMaxUse=32M\nRuntimeMaxUse=32M";
        extraConfig = ''
          SystemMaxUse=8M
          RuntimeMaxUse=8M
          MaxFileSec=1day
          MaxRetentionSec=3day
        '';
      };

      timesyncd.enable = true;
    };

    # ================================================================
    # System Tags
    # Mark this system as a server for identification
    # ================================================================
    system.nixos.tags = [ "server" ];

    # ================================================================
    # Systemd Configuration
    # Configure systemd behavior for server reliability
    #
    # /*
    # - coredump: Disabled to save disk space
    # - emergencyMode: Disabled so servers continue booting despite errors
    # - oomd: Out-Of-Memory daemon prevents system freezes by killing processes
    # */
    # ================================================================
    systemd = {
      coredump.enable = false;
      enableEmergencyMode = false;

      oomd = {
        enable = true;
        enableRootSlice = true;
        enableUserSlices = false; # Disabled - saves monitoring overhead
        enableSystemSlice = true;
      };
    };

    # ================================================================
    # Compressed Swap in RAM
    # Provides virtual memory without disk I/O using compression
    #
    # /*
    # - algorithm: zstd for fast and efficient compression
    # - priority: 100 ensures zram is used before disk swap
    # 25% of 2GB = 512MB zram (good balance for 2GB system)
    # */
    # ================================================================
    zramSwap = {
      enable = setDefault true;
      algorithm = setDefault "zstd";
      priority = setDefault 100;
      memoryPercent = setDefault 25;
    };
  };
}
