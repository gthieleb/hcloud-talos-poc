# helm-controller support and Argo CD registration

## helm-controller support (investigation result)

Upstream module used by this repository:

- `hcloud-talos/talos/hcloud`

Observed behavior:

- It uses Terraform `helm_template` data sources and `kubectl_manifest` resources to apply Cilium, HCCM, and optional Prometheus CRDs.
- It does not install or manage Flux `helm-controller`.

Conclusion:

- `helm-controller` is not a built-in feature of the module.
- If required, install Flux controllers separately after bootstrap.

## How kubeconfig is resolved in Talos module

The upstream module creates kubeconfig using Talos providers and then rewrites the API host according to `kubeconfig_endpoint_mode`.

Important modes:

- `public_ip`
- `private_ip`
- `public_endpoint` (uses `cluster_api_host`)
- `private_endpoint` (uses `cluster_api_host_private`)

For external Argo CD, recommended:

- set `cluster_api_host` to stable DNS name
- set `kubeconfig_endpoint_mode = "public_endpoint"`
- restrict Kubernetes API firewall (`firewall_kube_api_source`) to Argo CD egress CIDR(s)

## Argo CD cluster secret mapping

Use module output `kubeconfig_data`:

- `host` -> Argo cluster `server`
- `cluster_ca_certificate` -> `tlsClientConfig.caData` (base64 in JSON)
- `client_certificate` -> `tlsClientConfig.certData` (base64 in JSON)
- `client_key` -> `tlsClientConfig.keyData` (base64 in JSON)

See `docs/argocd-cluster-secret-example.yaml`.
