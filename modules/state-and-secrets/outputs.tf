output "bucket_name" {
  value = aws_s3_bucket.tfstate.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}

output "poc_backend_config" {
  value = {
    bucket         = aws_s3_bucket.tfstate.id
    dynamodb_table = aws_dynamodb_table.tf_lock.name
    key            = var.poc_state_key
  }
}

output "ci_backend_config" {
  value = {
    bucket         = aws_s3_bucket.tfstate.id
    dynamodb_table = aws_dynamodb_table.tf_lock.name
    key            = var.ci_state_key
  }
}

output "hcloud_token_secret_arn" {
  value = var.create_hcloud_token_secret ? aws_secretsmanager_secret.hcloud_token[0].arn : null
}
