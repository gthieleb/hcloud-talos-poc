module "cluster" {
  source = "../../modules/hcloud-talos-poc"

  hcloud_token       = var.hcloud_token
  cluster_name       = var.cluster_name
  location_name      = var.location_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  cilium_version     = var.cilium_version

  firewall_use_current_ip      = true
  control_plane_allow_schedule = true

  control_plane_nodes = [
    { id = 1, type = "cax11" },
    { id = 2, type = "cax11" },
    { id = 3, type = "cax11" }
  ]

  worker_nodes = []

  deploy_hcloud_ccm               = true
  deploy_cilium                   = true
  deploy_prometheus_operator_crds = true
}
