variable "bucket_name" {
  description = "S3 bucket name for Terraform state storage."
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for Terraform state locking."
  type        = string
}

variable "tags" {
  description = "Tags applied to created resources."
  type        = map(string)
  default     = {}
}

variable "poc_state_key" {
  description = "S3 object key used by the persistent POC environment state."
  type        = string
  default     = "poc/terraform.tfstate"
}

variable "ci_state_key" {
  description = "S3 object key used by the ephemeral CI environment state."
  type        = string
  default     = "ci/example-cluster/terraform.tfstate"
}

variable "create_hcloud_token_secret" {
  description = "Create AWS Secrets Manager secret placeholder for HCLOUD token used by CI."
  type        = bool
  default     = true
}

variable "hcloud_token_secret_name" {
  description = "Name of the optional AWS Secrets Manager secret for HCLOUD token."
  type        = string
  default     = "hcloud-talos-poc/hcloud-token"
}
