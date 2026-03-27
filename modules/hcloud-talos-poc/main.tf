module "talos" {
  source  = "hcloud-talos/talos/hcloud"
  version = "3.2.2"

  hcloud_token = var.hcloud_token

  cluster_name       = var.cluster_name
  location_name      = var.location_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  cilium_version     = var.cilium_version

  control_plane_nodes          = var.control_plane_nodes
  worker_nodes                 = var.worker_nodes
  control_plane_allow_schedule = var.control_plane_allow_schedule

  firewall_use_current_ip   = var.firewall_use_current_ip
  firewall_kube_api_source  = var.firewall_kube_api_source
  firewall_talos_api_source = var.firewall_talos_api_source

  cluster_api_host           = var.cluster_api_host
  kubeconfig_endpoint_mode   = var.kubeconfig_endpoint_mode
  talosconfig_endpoints_mode = var.talosconfig_endpoints_mode

  deploy_hcloud_ccm               = var.deploy_hcloud_ccm
  deploy_cilium                   = var.deploy_cilium
  deploy_prometheus_operator_crds = var.deploy_prometheus_operator_crds

  disable_arm        = var.disable_arm
  disable_x86        = var.disable_x86
  talos_image_id_x86 = var.talos_image_id_x86
  talos_image_id_arm = var.talos_image_id_arm
}
