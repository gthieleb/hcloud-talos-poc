module "cluster" {
  source = "../../modules/hcloud-talos-poc"

  hcloud_token       = var.hcloud_token
  cluster_name       = var.cluster_name
  location_name      = var.location_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  cilium_version     = var.cilium_version

  cluster_api_host           = var.cluster_api_host
  kubeconfig_endpoint_mode   = var.kubeconfig_endpoint_mode
  talosconfig_endpoints_mode = var.talosconfig_endpoints_mode
  cluster_api_host_private   = var.cluster_api_host_private

  enable_gateway               = var.enable_gateway
  expose_kube_api_via_gateway  = var.expose_kube_api_via_gateway
  expose_talos_api_via_gateway = var.expose_talos_api_via_gateway
  gateway_allowed_cidrs        = var.gateway_allowed_cidrs

  firewall_use_current_ip   = var.firewall_use_current_ip
  firewall_kube_api_source  = var.firewall_kube_api_source
  firewall_talos_api_source = var.firewall_talos_api_source

  control_plane_nodes          = var.control_plane_nodes
  worker_nodes                 = var.worker_nodes
  control_plane_allow_schedule = true

  deploy_hcloud_ccm               = true
  deploy_cilium                   = true
  deploy_prometheus_operator_crds = true
}
