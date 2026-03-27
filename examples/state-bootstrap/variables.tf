variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "bucket_name" {
  type = string
}

variable "dynamodb_table_name" {
  type = string
}

variable "hcloud_token_secret_name" {
  type    = string
  default = "hcloud-talos-poc/hcloud-token"
}
