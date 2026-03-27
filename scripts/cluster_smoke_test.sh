#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Waiting for nodes to be Ready"
kubectl wait --for=condition=Ready nodes --all --timeout=20m

echo "[2/5] Verifying 3 nodes are present"
node_count="$(kubectl get nodes --no-headers | wc -l | tr -d ' ')"
if [ "$node_count" != "3" ]; then
  echo "Expected 3 nodes, got ${node_count}"
  exit 1
fi

echo "[3/5] Verifying Cilium"
kubectl -n kube-system rollout status daemonset/cilium --timeout=10m
kubectl -n kube-system rollout status deployment/cilium-operator --timeout=10m

echo "[4/5] Verifying hcloud CCM"
kubectl -n kube-system rollout status deployment/hcloud-cloud-controller-manager --timeout=10m

echo "[5/5] Verifying Prometheus Operator CRDs"
kubectl get crd servicemonitors.monitoring.coreos.com >/dev/null
kubectl get crd prometheuses.monitoring.coreos.com >/dev/null

echo "Smoke test succeeded."
