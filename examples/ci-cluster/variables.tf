variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "cluster_name" {
  type    = string
  default = "hcloud-talos-ci"
}

variable "location_name" {
  type    = string
  default = "fsn1"
}

variable "talos_version" {
  type    = string
  default = "v1.12.2"
}

variable "kubernetes_version" {
  type    = string
  default = "1.35.0"
}

variable "cilium_version" {
  type    = string
  default = "1.18.5"
}

variable "enable_gateway" {
  type    = bool
  default = true
}

variable "expose_kube_api_via_gateway" {
  type    = bool
  default = true
}

variable "expose_talos_api_via_gateway" {
  type    = bool
  default = true
}

variable "gateway_allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
