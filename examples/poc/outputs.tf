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
