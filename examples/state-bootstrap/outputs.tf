output "poc_backend_config" {
  value = module.state_and_secrets.poc_backend_config
}

output "ci_backend_config" {
  value = module.state_and_secrets.ci_backend_config
}

output "hcloud_token_secret_arn" {
  value = module.state_and_secrets.hcloud_token_secret_arn
}
