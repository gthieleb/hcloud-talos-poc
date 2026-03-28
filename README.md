# hcloud-talos-poc

Terraform proof-of-concept for running a Talos Kubernetes cluster on Hetzner Cloud using the upstream module:

- `hcloud-talos/talos/hcloud`

This repository includes:

- a wrapper Terraform module for a 3-node control-plane cluster (workload scheduling on control planes enabled)
- bootstrap of HCCM, Cilium, and Prometheus Operator CRDs
- a dedicated `cax11` gateway VM with public IP and private NIC to expose Kubernetes API and Talos API as TCP pass-through
- investigation notes for helm-controller support and Argo CD cluster registration
- an example CI pipeline that provisions a cluster, runs Kubernetes smoke tests, and tears it down
- a small Terraform module to provision AWS S3/DynamoDB backend resources and a secret placeholder for CI

## What is configured

The wrapper module (`modules/hcloud-talos-poc`) sets sane defaults for this POC:

- `control_plane_nodes`: 3 nodes
- `worker_nodes`: none
- `control_plane_allow_schedule = true`
- `deploy_hcloud_ccm = true`
- `deploy_cilium = true`
- `deploy_prometheus_operator_crds = true`
- `enable_gateway = true`
- `expose_kube_api_via_gateway = true` (port `6443`)
- `expose_talos_api_via_gateway = true` (port `50000`)

## Private cluster with gateway exposure

The upstream module supports private endpoint modes, but node public IPs are still created.
This repository adds a dedicated gateway VM and routes API traffic through it:

- Gateway public port `6443` -> control-plane private VIP `:6443`
- Gateway public port `50000` -> first control-plane private IP `:50000`

Both exposures are optional and controlled independently:

- `expose_kube_api_via_gateway`
- `expose_talos_api_via_gateway`

If both are `false`, no gateway listener ports are exposed.

## helm-controller support investigation

See `docs/helm-controller-and-argocd.md`.

Short answer:

- The upstream module does not deploy Flux `helm-controller`.
- It renders Helm charts with Terraform (`helm_template`) and applies manifests via `kubectl_manifest`.
- If you need Flux controllers, install them separately (for example using Flux bootstrap) after cluster bootstrap.

## Argo CD kubeconfig/cluster registration

For external Argo CD (public reachability):

- prefer a stable API endpoint with DNS (`cluster_api_host`) mapped to the gateway public IP
- use `kubeconfig_endpoint_mode = "public_endpoint"` (auto-selected when gateway kube API exposure is enabled)
- allow Argo CD egress IP(s) through `gateway_allowed_cidrs`
- use module output `kubeconfig_data` to create an Argo CD cluster secret

Reference example:

- `docs/argocd-cluster-secret-example.yaml`

## Repository layout

- `modules/hcloud-talos-poc`: wrapper around upstream `hcloud-talos/talos/hcloud`
- `modules/state-and-secrets`: AWS bucket/lock table and CI secret placeholder
- `examples/poc`: stable POC stack
- `examples/ci-cluster`: ephemeral CI test stack
- `.github/workflows/ci.yml`: validation + e2e lifecycle
- `scripts/cluster_smoke_test.sh`: Kubernetes checks used in CI
- `scripts/check_gateway_ports.sh`: gateway reachability checks for ports 6443/50000

## Required CI secrets

The e2e pipeline requires these GitHub repository secrets:

- `HCLOUD_TOKEN`
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `TFSTATE_BUCKET`
- `TFSTATE_DYNAMODB_TABLE`

Optional:

- `TFSTATE_BUCKET_REGION` (defaults to `AWS_REGION`)

## Quick start

1. Configure backend resources with `modules/state-and-secrets` (or existing bucket/table).
2. Copy and adjust `examples/poc/terraform.tfvars.example`.
3. Run:

```bash
terraform -chdir=examples/poc init
terraform -chdir=examples/poc apply
```

4. Verify gateway outputs and export kubeconfig:

```bash
terraform -chdir=examples/poc output gateway_public_ipv4
terraform -chdir=examples/poc output --raw kubeconfig > ./kubeconfig
export KUBECONFIG=$PWD/kubeconfig
kubectl get nodes
```
