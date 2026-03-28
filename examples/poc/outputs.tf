output "kubeconfig" {
  value     = module.cluster.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = module.cluster.talosconfig
  sensitive = true
}

output "kubeconfig_data" {
  value     = module.cluster.kubeconfig_data
  sensitive = true
}

output "public_ipv4_list" {
  value = module.cluster.public_ipv4_list
}

output "gateway_public_ipv4" {
  value = module.cluster.gateway_public_ipv4
}

output "gateway_exposed_ports" {
  value = module.cluster.gateway_exposed_ports
}
