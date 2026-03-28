provider "hcloud" {
  token = var.hcloud_token
}

locals {
  gateway_enabled      = var.enable_gateway && (var.expose_kube_api_via_gateway || var.expose_talos_api_via_gateway)
  gateway_private_ip   = coalesce(var.gateway_private_ip, cidrhost(var.node_ipv4_cidr, 10))
  kube_private_target  = cidrhost(var.node_ipv4_cidr, 100)
  talos_private_target = cidrhost(var.node_ipv4_cidr, 101)
  kubeconfig_endpoint_mode = coalesce(
    var.kubeconfig_endpoint_mode,
    local.gateway_enabled && var.expose_kube_api_via_gateway ? "public_endpoint" : "private_ip"
  )
}

resource "hcloud_primary_ip" "gateway_ipv4" {
  count = local.gateway_enabled ? 1 : 0

  name          = "${var.cluster_name}-gateway-ipv4"
  location      = var.location_name
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false

  labels = {
    cluster = var.cluster_name
    role    = "gateway"
  }
}

module "talos" {
  source  = "hcloud-talos/talos/hcloud"
  version = "3.2.2"

  hcloud_token = var.hcloud_token

  cluster_name             = var.cluster_name
  location_name            = var.location_name
  talos_version            = var.talos_version
  kubernetes_version       = var.kubernetes_version
  cilium_version           = var.cilium_version
  cluster_api_host         = coalesce(var.cluster_api_host, local.gateway_enabled && var.expose_kube_api_via_gateway ? hcloud_primary_ip.gateway_ipv4[0].ip_address : null)
  cluster_api_host_private = var.cluster_api_host_private

  network_ipv4_cidr = var.network_ipv4_cidr
  node_ipv4_cidr    = var.node_ipv4_cidr
  pod_ipv4_cidr     = var.pod_ipv4_cidr
  service_ipv4_cidr = var.service_ipv4_cidr

  control_plane_nodes          = var.control_plane_nodes
  worker_nodes                 = var.worker_nodes
  control_plane_allow_schedule = var.control_plane_allow_schedule

  firewall_use_current_ip   = var.firewall_use_current_ip
  firewall_kube_api_source  = var.firewall_kube_api_source
  firewall_talos_api_source = var.firewall_talos_api_source

  kubeconfig_endpoint_mode   = local.kubeconfig_endpoint_mode
  talosconfig_endpoints_mode = var.talosconfig_endpoints_mode

  deploy_hcloud_ccm               = var.deploy_hcloud_ccm
  deploy_cilium                   = var.deploy_cilium
  deploy_prometheus_operator_crds = var.deploy_prometheus_operator_crds

  disable_arm        = var.disable_arm
  disable_x86        = var.disable_x86
  talos_image_id_x86 = var.talos_image_id_x86
  talos_image_id_arm = var.talos_image_id_arm
}

resource "hcloud_firewall" "gateway" {
  count = local.gateway_enabled ? 1 : 0

  name = "${var.cluster_name}-gateway"

  dynamic "rule" {
    for_each = var.expose_kube_api_via_gateway ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "6443"
      source_ips = var.gateway_allowed_cidrs
    }
  }

  dynamic "rule" {
    for_each = var.expose_talos_api_via_gateway ? [1] : []
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = "50000"
      source_ips = var.gateway_allowed_cidrs
    }
  }

  labels = {
    cluster = var.cluster_name
    role    = "gateway"
  }
}

resource "hcloud_server" "gateway" {
  count = local.gateway_enabled ? 1 : 0

  name        = "${var.cluster_name}-gateway"
  location    = var.location_name
  server_type = var.gateway_server_type
  image       = var.gateway_image
  user_data = templatefile("${path.module}/templates/gateway-cloud-init.tftpl", {
    expose_kube_api      = var.expose_kube_api_via_gateway
    expose_talos_api     = var.expose_talos_api_via_gateway
    kube_private_target  = local.kube_private_target
    talos_private_target = local.talos_private_target
  })

  firewall_ids = [hcloud_firewall.gateway[0].id]

  labels = {
    cluster = var.cluster_name
    role    = "gateway"
  }

  public_net {
    ipv4_enabled = true
    ipv4         = hcloud_primary_ip.gateway_ipv4[0].id
    ipv6_enabled = false
  }

  network {
    network_id = module.talos.hetzner_network_id
    ip         = local.gateway_private_ip
    alias_ips  = []
  }
}
