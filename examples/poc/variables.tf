variable "hcloud_token" {
  type      = string
  sensitive = true
}

variable "cluster_name" {
  type    = string
  default = "hcloud-talos-poc"
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

variable "cluster_api_host" {
  type    = string
  default = null
}

variable "cluster_api_host_private" {
  type    = string
  default = null
}

variable "kubeconfig_endpoint_mode" {
  type    = string
  default = null
}

variable "talosconfig_endpoints_mode" {
  type    = string
  default = "private_ip"
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

variable "firewall_use_current_ip" {
  type    = bool
  default = true
}

variable "firewall_kube_api_source" {
  type    = list(string)
  default = null
}

variable "firewall_talos_api_source" {
  type    = list(string)
  default = null
}

variable "control_plane_nodes" {
  type = list(object({
    id   = number
    type = string
  }))

  default = [
    { id = 1, type = "cax11" },
    { id = 2, type = "cax11" },
    { id = 3, type = "cax11" }
  ]
}

variable "worker_nodes" {
  type = list(object({
    id   = number
    type = string
  }))
  default = []
}
