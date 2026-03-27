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
