{ lib, ... }:
{
  imports = [
    # Web Services & Apps
    ./linkding
    ./jotty
    ./memos
    ./blog
    ./fossflow

    # Media
    ./audiobookshelf

    # Networking & Proxy
    ./tailscale
    ./nginx
    ./traefik
    ./traefikk # Note: duplicate of traefik?

    # DNS & Network Services
    ./adguard
    ./ad-guard # Note: duplicate of adguard?

    # Monitoring & Observability
    ./glance
    ./uptime-kuma
    ./grafana
    ./promtail
    ./prometheusNode

    # Storage & Object Storage
    ./minio
    ./garage
    ./garage-webui

    # Databases
    ./postgres
    ./myslql # Note: typo? should be mysql?

    # Automation & Workflows
    ./n8n

    # Container Management
    ./dockhand
    ./hawser
    ./zerobyte

    # Git & CI/CD
    ./forgejo
    ./forgejo-runner

    # Kubernetes
    ./rancher
    ./vault
  ];
}
