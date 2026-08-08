---
id: HML-011
title: Debug Longhorn Gateway Timeout issue
status: Done
assignee: []
created_date: '2026-08-08 15:22'
updated_date: '2026-08-08 15:39'
labels: []
dependencies: []
priority: high
type: bug
ordinal: 8000
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
Longhorn service was working fine yesterday but today is returning Gateway Timeout errors when accessing http://longhorn.l.thein3rovert.com/. ArgoCD may also be involved. Need to investigate k3s cluster state, ingress configuration, service status, and pod health to identify root cause and restore service.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [x] #1 Longhorn UI is accessible at http://longhorn.l.thein3rovert.com/ without timeout errors
- [x] #2 Root cause identified and documented
- [x] #3 Service remains stable after fix
<!-- AC:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
## Debugging Plan for K3s Networking/Gateway Timeout Issues

### 1. Initial Service Check
```bash
# Check pod status
kubectl get pods -n longhorn-system
kubectl get pods -n kube-system | grep -E "coredns|traefik"

# Check services and ingress
kubectl get svc -n longhorn-system
kubectl get ingress -n longhorn-system
kubectl describe ingress longhorn-ui -n longhorn-system
```

**Look for:** Pods stuck in CrashLoopBackOff, services without endpoints, ingress misconfigurations

### 2. Test DNS Resolution
```bash
# Test DNS from within cluster
kubectl run dnstest --image=busybox:latest --rm -i --restart=Never -- nslookup kubernetes.default.svc.cluster.local

# Test DNS to specific service
kubectl run dnstest --image=busybox:latest --rm -i --restart=Never -- nslookup longhorn-frontend.longhorn-system.svc.cluster.local

# Check CoreDNS status
kubectl get pods -n kube-system -l k8s-app=kube-dns -o wide
kubectl logs -n kube-system --selector=k8s-app=kube-dns --tail=50
```

**Look for:** DNS timeout errors, "connection timed out; no servers could be reached", CoreDNS pod issues

### 3. Test Network Connectivity
```bash
# Get CoreDNS endpoint
kubectl get endpoints -n kube-system kube-dns

# Test ping to DNS service IP (10.43.0.10)
kubectl run nettest --image=busybox:latest --rm -i --restart=Never -- ping -c 3 10.43.0.10

# Test connectivity to service directly
kubectl run curl-test --image=curlimages/curl:latest --rm -i --restart=Never -- curl -v -m 5 http://longhorn-frontend.longhorn-system.svc.cluster.local:80
```

**Look for:** 100% packet loss, connection timeouts, network unreachable errors

### 4. Check Flannel/CNI (Critical for K3s)
```bash
# Check node status
kubectl get nodes -o wide

# SSH to each node and check flannel VXLAN interface
ssh k3s-server "ip addr show flannel.1"
ssh lincoln "ip addr show flannel.1"
ssh raven "ip addr show flannel.1"

# Check k3s logs on each node
ssh k3s-server "sudo journalctl -u k3s -n 100 --no-pager | grep -E 'flannel|vxlan|error|timeout'"
```

**Look for:** 
- Missing flannel.1 interface on any node
- "external interface not found, retrying" messages
- Connection timeout errors to kubelet (10.42.x.x:10250)
- VXLAN errors

### 5. Check iptables Rules
```bash
# Check if iptables rules exist for DNS service
ssh k3s-server "sudo iptables-save | grep -A 5 '10.43.0.10'"
```

**Look for:** Missing KUBE-SERVICES chains, no rules for kube-dns

### 6. Check Ingress Controller
```bash
# Check Traefik pods
kubectl get pods -n kube-system | grep traefik

# Check Traefik logs for errors
kubectl logs -n kube-system traefik-<pod-name> --tail=100 | grep -i "longhorn\|timeout\|error"
```

**Look for:** Traefik crashes, timeout errors, routing issues

### 7. Resolution Steps

**If flannel.1 interface is missing:**
```bash
# Restart k3s on the affected node
ssh <node> "sudo systemctl restart k3s"

# If restart doesn't work, reboot the node
ssh <node> "sudo reboot"

# Wait ~60 seconds and verify flannel interface is back
ssh <node> "ip addr show flannel.1"
```

**If DNS is broken but flannel exists:**
```bash
# Delete and restart CoreDNS pod
kubectl delete pod -n kube-system <coredns-pod-name>

# Wait for new pod to come up
kubectl get pods -n kube-system -w | grep coredns
```

**If iptables rules are missing:**
```bash
# This usually indicates kube-proxy issues - restart k3s
ssh k3s-server "sudo systemctl restart k3s"
```

### 8. Final Verification
```bash
# Test DNS resolution
kubectl run dnstest --image=busybox:latest --rm -i --restart=Never --timeout=10s -- nslookup kubernetes.default.svc.cluster.local

# Test service accessibility
curl -I http://longhorn.l.thein3rovert.com/

# Check all nodes are Ready with flannel
kubectl get nodes
for node in k3s-server lincoln raven; do 
  echo "=== $node ==="; 
  ssh $node "ip addr show flannel.1 | grep inet"; 
done
```

**Success criteria:**
- DNS resolves successfully
- HTTP 200 from Longhorn UI
- All nodes show flannel.1 interface with 10.42.x.0/32 IP
- No timeout errors in k3s logs

### Common Issues and Quick Fixes

| Symptom | Likely Cause | Quick Fix |
|---------|-------------|-----------|
| Gateway Timeout | DNS or networking issue | Check flannel interfaces first |
| DNS timeout | Missing flannel.1 interface | Restart k3s or reboot node |
| Pods can't reach services | Missing iptables rules | Restart k3s on control plane |
| CoreDNS warnings | Upstream DNS issue | Check /etc/resolv.conf, may need upstream DNS fix |
| "external interface not found" | Flannel failed to start | Reboot node to reinitialize networking |
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## Root Cause
The flannel.1 VXLAN interface was missing on all k3s nodes (k3s-server, lincoln, raven), causing complete DNS and pod networking failure. This manifested as:
- Gateway timeouts for Longhorn UI
- DNS resolution failures (100% packet loss to kube-dns)
- CoreDNS warnings: "Nameserver limits were exceeded" (27k+ occurrences)
- k3s logs showing: "external interface not found, retrying in 30s"

## Resolution
1. Restarted k3s service on k3s-server (flannel.1 interface restored)
2. Rebooted lincoln and raven nodes to fully reinitialize networking
3. Verified DNS resolution working (nslookup successful)
4. Confirmed Longhorn UI accessible (HTTP 200 OK)

## Verification
- All nodes show Ready status
- DNS queries resolving properly
- Longhorn UI responding at http://longhorn.l.thein3rovert.com/
- Flannel VXLAN interfaces present on all nodes

## What Causes Flannel VXLAN Failures

### Common Causes

1. **Ungraceful Node Reboots/Crashes** - Power loss, hard reboot, kernel panics. Flannel doesn't reinitialize VXLAN interface on startup.

2. **Network Interface Changes** - Primary interface down, IP changes, network adapter resets, VPN state changes.

3. **Kernel Module Issues** - VXLAN module not loaded, kernel updates without reboot, module conflicts.

4. **Resource Exhaustion** - OOM killing k3s, disk full, too many file descriptors.

5. **Time Sync Issues** - Clock drift, NTP failures, etcd consensus problems.

6. **Firewall Changes** - Blocking VXLAN traffic (UDP 8472), iptables rules flushed.

7. **Etcd Corruption** - Flannel config lost, split-brain scenarios.

8. **System Updates** - Kernel/systemd updates requiring reboot.

### Prevention Strategies

**1. Monitor Flannel Health**
```bash
# Check script every 5 min (cron)
for node in k3s-server lincoln raven; do
  if ! ssh $node "ip addr show flannel.1 &>/dev/null"; then
    ssh $node "sudo systemctl restart k3s"
  fi
done
```

**2. Allow VXLAN Traffic**
```bash
sudo ufw allow 8472/udp comment "Flannel VXLAN"
```

**3. Enable Time Sync**
```bash
sudo systemctl enable --now systemd-timesyncd
```

**4. Graceful Node Maintenance**
```bash
kubectl drain <node> --ignore-daemonsets
ssh <node> "sudo reboot"
kubectl uncordon <node>
```

**5. Backup Etcd Daily**
```bash
sudo k3s etcd-snapshot save --name backup-$(date +%Y%m%d)
```

**6. Persistent Logs**
```bash
# /etc/systemd/journald.conf
[Journal]
Storage=persistent
SystemMaxUse=1G
```

### What Can't Be Prevented

- Hardware failures
- ISP/data center outages  
- Kernel bugs
- Cosmic rays (bit flips)

Focus on: Quick detection + fast recovery + HA

### Best Practices

✅ Monitor flannel every 5 min
✅ Auto-restart k3s if flannel missing
✅ Allow UDP 8472 in firewall
✅ Keep NTP enabled
✅ Drain before reboot
✅ Backup etcd daily
⚠️ Avoid hard reboots
⚠️ Test updates on one node first
<!-- SECTION:NOTES:END -->
