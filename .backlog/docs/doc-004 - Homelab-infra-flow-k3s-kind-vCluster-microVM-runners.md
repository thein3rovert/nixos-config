---
id: doc-004
title: Homelab infra flow - k3s kind vCluster microVM runners
type: guide
created_date: '2026-09-21 19:29'
---
# Prod-like Homelab Flow - k3s, kind, vCluster, microVMs, Runners

From debug session 2026-09-21: k3s-server crash-looped because etcd could not bind to 100.85.190.19:2380 after Tailscale logged out. Fixed with `tailscale up` CLI.

## 1. k3s (main cluster)
- **What:** Lightweight Kubernetes, single binary with embedded etcd.
- **Use for:** Real, persistent workloads. Home prod.
- **Infra flow:** Run on Proxmox VMs, 3x server nodes for HA when third cluster is ready. Tailscale for private API/etcd traffic (2379/2380/6443).

## 2. New master control plane (migration)
- **What:** New primary server that agents join, old k3s-server retired.
- **Flow:** 1) Build new Proxmox VM, install same k3s version 2) Join as `k3s server --server https://old-ip:6443 --token <token>` 3) Verify `kubectl get nodes`, etcd members 4) Repoint agents `--server https://new-ip:6443` 5) Remove old: `kubectl delete node k3s-server`, `etcd member remove`.
- **Why:** Clean promote without downtime, keep certs/token consistent.

## 3. kind (on-demand clusters)
- **What:** Full Kubernetes in Docker containers. Separate control-plane, not a k3s node.
- **Use for:** Throwaway learning, upgrade dry-runs, ephemeral CI.
- **Flow:** `kind create cluster --name test`, try breaking change, `kind delete cluster`. Lives on laptop or runner VM with Docker.

## 4. Multi-cluster
- **What:** Multiple independent clusters that cooperate (not worker nodes of each other).
- **Use for:** Isolation, DR, edge + central, prod vs lab.
- **Scenario:** Prod apps stay on k3s. Test promotion on kind first. If kind dies, prod is safe.
- **Why:** Blast-radius control and locality.

## 5. vCluster (virtual cluster)
- **What:** Virtual control-plane inside k3s, shares nodes/CPU/RAM. Like containers in a VM.
- **Ephemeral or persistent:** Both, you decide.
- **Use for:** Team isolation, dev previews, safe operator testing with no extra VMs.

## 6. MicroVMs (Kata / Firecracker)
- **What:** Tiny VMs with container speed, VM isolation.
- **Use for:** Secure sandboxing, disposable k3s workers: spin up, `k3s agent --server`, kill.
- **Why:** Stronger isolation than plain containers, faster than full VMs.

## 7. Custom runners
- **What:** Ephemeral CI runners.
- **Flow:** kind or microVM spins on demand for a job, runs it, tears down. Persistent runners stay on k3s only if always needed.
- **Why:** Cheap, isolated, no noisy-neighbor on prod.

## Recommended homelab flow
1. Prod stays on k3s (Proxmox, Tailscale private net).
2. vClusters for per-team/app isolation inside k3s.
3. kind for learning + pre-prod validation.
4. MicroVMs for secure ephemeral workers/runners.
5. Multi-cluster link prod + lab only when you need failover or edge.
