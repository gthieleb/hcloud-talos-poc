output "kubeconfig" {
  value     = module.cluster.kubeconfig
  sensitive = true
}

output "public_ipv4_list" {
  value = module.cluster.public_ipv4_list
}
