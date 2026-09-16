---
id: HML-042
title: Deploy Technitium DNS on zeke LXC and migrate from AdGuard
status: In Progress
assignee: []
created_date: '2026-09-16 11:56'
updated_date: '2026-09-16 12:46'
labels:
  - dns
  - technitium
  - zeke
  - proxmox
  - terraform
  - nixos
dependencies: []
modified_files:
  - terraform/envs/prod/main.tf
  - modules/nixos/services/networking/technitium/default.nix
  - modules/nixos/services/networking/default.nix
  - modules/base/networks/default.nix
  - modules/base/networks/ip-addresses.nix
  - modules/base/networks/ip-registry.nix
  - modules/snippets/networkMap/default.nix
  - modules/nixos/services/networking/traefikk/default.nix
  - modules/nixos/services/monitoring/glance/config/glance.yml
  - hosts/zeke/default.nix
  - hosts/zeke/configuration.nix
  - hosts/zeke/lxc.nix
  - hosts/zeke/secret.nix
  - hosts/nixos/secrets.nix
  - flake.nix
priority: high
type: task
ordinal: 57000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Replace AdGuardHome (running on the finn LXC) with Technitium DNS running on a new dedicated LXC called zeke, as the first of three planned redundant DNS resolvers. Technitium is preferred for its authoritative zones, replication, and modern protocol support. AdGuard stays live on finn in parallel until Technitium proves stable, then finn is retired.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 zeke LXC provisioned via Terraform for_each dns-container module and reachable on 192.168.0.106 and its Tailscale IP
- [x] #2 Technitium container runs healthy on zeke and admin dashboard is accessible on port 5380
- [x] #3 Technitium resolves public DNS queries and serves the local l.thein3rovert.com wildcard zone
- [ ] #4 Tailscale global nameservers cut over from finn to zeke with finn kept as fallback, then finn removed once stable
- [ ] #5 AdGuard on finn retired after Technitium proves stable
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
1. Provision zeke LXC via Terraform dns-container for_each module with per-node vmid, node, storage, and ostemplate (zeke is 106 on mount-weather). 2. Create NixOS technitium service module as a host-networked oci-container with agenix admin password, firewall for 53/5380/443/853, and ip_local_port_range sysctl. 3. Scaffold hosts/zeke (configuration, lxc, secret), wire flake.nix nixosConfigurations and colmenaHive, register IPs and networkMap. 4. Create technitium-env.age and rekey tailscale-auth.age in secret-vault for the zeke host key. 5. Deploy via colmena with targetUser root for bootstrap since a fresh LXC has no thein3rovert user, then verify the container is healthy. 6. Fix module bugs found in crash logs: forwarders must be comma-separated not semicolon, recursion enum must be capitalized Allow/Deny/AllowOnlyForPrivateNetworks/UseSpecifiedNetworkACL; wipe the stale volume for a clean first-start. 7. Configure the l.thein3rovert.com wildcard zone in the Technitium dashboard mirroring the AdGuard rewrite (*.l.thein3rovert.com to 100.105.217.77). 8. Cut over Tailscale Global nameservers from finn (100.91.36.84) to zeke (100.74.26.17), keep finn as fallback, then remove finn. 9. Retire AdGuard on finn after a stability period.
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-09-16: zeke LXC created via terraform apply (module.dns-container[zeke], vmid 106 on mount-weather, 192.168.0.106). Hit 403 on fuse feature flag since Proxmox API tokens can only toggle nesting; dropped enable_fuse for DNS as FUSE is not needed. Pre-existing roan app-container drift (features.mount nfs to null) applied cleanly and is unrelated to DNS.

2026-09-16: Colmena push failed as thein3rovert because a fresh LXC has no thein3rovert user yet; switched colmena targetUser to root for bootstrap and deploy succeeded. zeke is up and joined the tailnet as 100.74.26.17 (confirmed via tailscale status on host).

2026-09-16: Technitium crash-looped on first start. Root cause from container logs: DNS_SERVER_FORWARDERS used semicolon separator which Technitium rejects as invalid character 59; official docs require comma-separated. Also fixed DNS_SERVER_RECURSION enum to capitalized Allow/Deny/AllowOnlyForPrivateNetworks/UseSpecifiedNetworkACL. Verified via nix eval (forwarders 1.1.1.1,8.8.8.8 and recursion AllowOnlyForPrivateNetworks). Wiped /var/lib/technitium of partial crashed state so fixed env vars apply on clean first-start.

2026-09-16: Verified healthy after redeploy. podman ps shows technitium Up and stable. dotnet process bound to :53 tcp and udp plus :5380. Startup log shows started successfully with no forwarder errors. Dashboard returns HTTP 200 with title Technitium DNS Server. NOTE: commented name2 placeholder in terraform still shows vmid 106 which duplicates zeke; change to a free ID such as 107 before uncommenting.

2026-09-16: Added wildcard A record in Technitium dashboard (l.thein3rovert.com zone: * to 100.105.217.77, TTL 3600, comment Wildcard for my local dns), mirroring the AdGuard rewrite. Verified via dig against 100.74.26.17: test123.l.thein3rovert.com returns 100.105.217.77, grafana.l.thein3rovert.com returns 100.105.217.77, and example.com returns public IPs. AC #3 complete.

2026-09-16: Discussed wildcard vs explicit records and the 100.105.217.77 ingress IP. Confirmed the wildcard must follow Traefik (currently on emily/nixos at 100.105.217.77) since clients hit Traefik which proxies to backends via ipRegistry. Agreed future plan is to move Traefik to a dedicated LXC and repoint the wildcard at its Tailscale IP then; sticking with current Traefik placement for now. No separate task created for the Traefik move yet; revisit after DNS is stable.

2026-09-16: User ran parity checks from tailnet client. dig @100.74.26.17 and @192.168.0.106 both return NOERROR with root NS records (live resolver on both interfaces). grafana/traefik/memo .l.thein3rovert.com return 100.105.217.77 identically on finn (100.91.36.84) and zeke (100.74.26.17). Zeke confirmed as drop-in replacement; ready for Tailscale cutover (AC #4).

RUNBOOK - DNS testing from any tailnet client:
dig @100.74.26.17 example.com +short
# ^ public resolution (forwarders OK if IPs return)
dig @100.74.26.17 grafana.l.thein3rovert.com +short
# ^ expect 100.105.217.77 (wildcard zone OK)
dig @100.91.36.84 <name>.l.thein3rovert.com +short   # finn/AdGuard
dig @100.74.26.17 <name>.l.thein3rovert.com +short   # zeke/Technitium
# ^ parity check: both must match before cutover
dig @100.74.26.17            # bare root-NS query, proves live resolver
dig @192.168.0.106 <name>    # same tests over LAN IP (both interfaces must answer)
dig <name> +short            # no @server: tests YOUR machine's current resolver (post-cutover check)
dig -x 100.105.217.77 @100.74.26.17 +short   # reverse lookup

RUNBOOK - host diagnostics over SSH (as root@192.168.0.106 or tailscale IP):
systemctl is-active podman-technitium
podman ps --filter name=technitium --format "{{.Names}} {{.Status}}"
# ^ container must show Up and stable, not restarting-looping
journalctl -u podman-technitium --no-pager -n 50
# ^ crash diagnosis: look for DnsClientException / Invalid domain name / forwarder parse errors
ss -tlnp | grep -E "5380|:53" ; ss -ulnp | grep ":53"
# ^ dotnet (Technitium) must own :53 tcp+udp and :5380; systemd-resolve must only be on :5355 (LLMNR), never :53
curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:5380/
# ^ expect 200; dashboard title is Technitium DNS Server
tailscale status --peers=false ; tailscale ip -4
# ^ host identity and tailnet IP
ls -la /var/lib/technitium/
# ^ a healthy first-start writes dns.config plus auth/blocklists/zones/stats dirs; no dns.config means init never completed
# NUCLEAR (fresh or broken installs only, destroys zones+password):
systemctl stop podman-technitium; rm -rf /var/lib/technitium/*; systemctl start podman-technitium

RUNBOOK - repo checks, deploy, and secrets (from nixos-config root):
nix-instantiate --parse <file>   # nix syntax check, run per edited file
nix eval --json '.#nixosConfigurations.zeke.config.nixosSetup.services.technitium.enable'
# ^ must be true
nix eval --json '.#nixosConfigurations.zeke.config.virtualisation.oci-containers.containers.technitium.environment.DNS_SERVER_FORWARDERS'
# ^ must be "1.1.1.1,8.8.8.8" (comma, never semicolon)
nix eval --raw '.#nixosConfigurations.zeke.config.virtualisation.oci-containers.containers.technitium.environment.DNS_SERVER_RECURSION'
# ^ must be AllowOnlyForPrivateNetworks (capitalized)
cd terraform/envs/prod && terraform fmt -check main.tf && terraform plan && terraform apply
# ^ plan first: confirm VMIDs free (in use: 51 finn, 101 becca, 102 trikru, 103 roan, 105 nightblood, 106 zeke, 111 raven, 112 lincoln, 120 github-runner)
colmena apply --on zeke
# ^ first bootstrap of a fresh LXC needs targetUser=root in flake.nix colmenaHive (thein3rovert user does not exist yet); root stays valid afterwards since its key is authorized in hosts/zeke/configuration.nix
SECRETS (secret-vault repo, manual): technitium/technitium-env.age must contain exactly DNS_SERVER_ADMIN_PASSWORD=<password>; rekey tailscale/shared/tailscale-auth.age for each new host key; identity path is /home/thein3rovert/.ssh/thein3rovert_<hostname>
GOTCHAS: (1) Proxmox API tokens can only toggle the nesting feature flag; fuse/keyctl/mount/mknod need root@pam, so never set enable_fuse via token-driven terraform. (2) Technitium reads env vars only on first start when no config exists; after any env fix, wipe /var/lib/technitium and restart. (3) systemd-resolved stub listener must stay disabled (DNSStubListener=no) or :53 conflicts. (4) Tailscale queries Global nameservers in listed order with fallback, so cut over by adding zeke above finn, then removing finn later.

2026-09-16: Tailscale cutover phase 1 done. Global nameservers now list 100.74.26.17 (zeke) first with 100.91.36.84 (finn) kept as fallback, Override DNS servers ON. Checked zeke app log: block list zone loaded, dashboard update-checks arriving from 100.105.217.77, but no real client DNS queries yet (propagation + client DNS cache lag expected). AC #4 stays open until finn is removed after a stability period. Verify with: dig <name> (no @server) and confirm SERVER line shows 100.74.26.17, or watch live queries in Technitium dashboard Logs; finn AdGuard query log should go quiet except fallback hits.

2026-09-16: Direct query dig @100.74.26.17 grafana.l.thein3rovert.com returns 3600 IN A 100.105.217.77 with flags qr aa rd ra (authoritative answer bit set) from SERVER 100.74.26.17. Confirms zeke serves the wildcard zone authoritatively and correctly. Earlier TTL-10 answer via Tailscale proxy (SERVER 100.100.100.100) therefore came from finn/AdGuard, proving the laptop client had not yet picked up the new nameserver order (propagation/cache lag). Next: force client Tailscale DNS refresh (tailscale down/up or tailscaled restart), then re-test without @server expecting TTL 3600.

2026-09-16: Cross-device test from marcus shows Tailscale does not strictly order upstreams. testing.l.thein3rovert.com via proxy returned aa bit with TTL 3600 (zeke answered), while fossflow.l.thein3rovert.com seconds later returned no aa bit with TTL 10 (finn answered). Same proxy, different upstreams per query, so Tailscale races or fails over between listed nameservers rather than pinning zeke-first. Both return the correct IP so clients are unaffected. Definitive cutover proof must come server-side: live client queries in Technitium dashboard Logs, and finn AdGuard query log going quiet. Laptop sticking to TTL 10 is consistent with this racing, not necessarily stale config.

2026-09-16: Dashboard confirms zeke serving real traffic post-cutover. Last Hour: 790 total queries (748 No Error 94.68%, 0 Server Failure, 42 NX Domain 5.32% which is normal background noise, 0 Refused), 126 Authoritative / 393 Recursive / 267 Cached, 4 Blocked, 0 Dropped, 9 Clients. Traffic spike begins 13:28 matching the Tailscale console flip. 7 Zones, 654 Cache entries, 260,320 Block List entries loaded. Top client 100.105.217.77 with 337 queries. Both resolvers sharing load as expected; holding finn as fallback until stability is proven before removal (AC #4) and AdGuard retirement (AC #5).

2026-09-16: Wired Technitium dashboard into Traefik (traefikk). Added homelab.ipRegistry.technitium (zeke tailscaleIp 100.74.26.17 + networkMap port 5380, url auto-built), plus traefikk http service and router for vHost technitium.l.thein3rovert.com on entryPoint web. Verified via nix eval on nixos host: backend url 100.74.26.17:5380, rule Host(technitium.l.thein3rovert.com), server http://100.74.26.17:5380/. Requires redeploy of the nixos host (Traefik lives there) via colmena apply --on nixos before http://technitium.l.thein3rovert.com goes live; the wildcard DNS already resolves that name to Traefik on both resolvers.

2026-09-16: Added Technitium to Glance dashboard (glance.yml Infrastructure monitor, after AdGuard): title Technitium, url http://technitium.l.thein3rovert.com, icon di:technitium.png. Takes effect on next redeploy of whichever host runs Glance. Note: this URL goes through Traefik, so the nixos host redeploy (traefikk router) must land first or the Glance monitor will show it down.
<!-- SECTION:NOTES:END -->
