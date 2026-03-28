output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "kubeconfig_data" {
  value     = module.talos.kubeconfig_data
  sensitive = true
}

output "public_ipv4_list" {
  value = module.talos.public_ipv4_list
}

output "firewall_id" {
  value = module.talos.firewall_id
}

output "hetzner_network_id" {
  value = module.talos.hetzner_network_id
}

output "gateway_public_ipv4" {
  value = length(hcloud_primary_ip.gateway_ipv4) > 0 ? hcloud_primary_ip.gateway_ipv4[0].ip_address : null
}

output "gateway_private_ipv4" {
  value = length(hcloud_server.gateway) > 0 ? local.gateway_private_ip : null
}

output "gateway_exposed_ports" {
  value = {
    kube_api  = var.expose_kube_api_via_gateway && var.enable_gateway
    talos_api = var.expose_talos_api_via_gateway && var.enable_gateway
  }
}
