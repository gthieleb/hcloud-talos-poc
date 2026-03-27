provider "aws" {
  region = var.aws_region
}

module "state_and_secrets" {
  source = "../../modules/state-and-secrets"

  bucket_name              = var.bucket_name
  dynamodb_table_name      = var.dynamodb_table_name
  hcloud_token_secret_name = var.hcloud_token_secret_name

  tags = {
    project = "hcloud-talos-poc"
    env     = "shared"
  }
}
