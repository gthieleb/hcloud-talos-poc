output "kubeconfig" {
  value     = module.cluster.kubeconfig
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
