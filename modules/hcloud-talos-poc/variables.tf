variable "hcloud_token" {
  description = "Hetzner Cloud API token."
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Cluster name."
  type        = string
}

variable "location_name" {
  description = "Hetzner location (for example fsn1)."
  type        = string
  default     = "fsn1"
}

variable "talos_version" {
  description = "Talos version for machine configuration generation."
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
}

variable "cilium_version" {
  description = "Cilium chart version."
  type        = string
  default     = "1.18.5"
}

variable "control_plane_nodes" {
  description = "Control-plane node definitions."
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
  description = "Worker node definitions. Empty by default for control-plane-only cluster."
  type = list(object({
    id   = number
    type = string
  }))
  default = []
}

variable "control_plane_allow_schedule" {
  description = "Allow workloads on control-plane nodes."
  type        = bool
  default     = true
}

variable "firewall_use_current_ip" {
  description = "Use current public IP for kube/talos API firewall rules."
  type        = bool
  default     = true
}

variable "firewall_kube_api_source" {
  description = "Explicit source CIDRs for Kubernetes API access. Overrides firewall_use_current_ip when set."
  type        = list(string)
  default     = null
}

variable "firewall_talos_api_source" {
  description = "Explicit source CIDRs for Talos API access. Overrides firewall_use_current_ip when set."
  type        = list(string)
  default     = null
}

variable "cluster_api_host" {
  description = "Optional stable public DNS hostname for Kubernetes API endpoint."
  type        = string
  default     = null
}

variable "kubeconfig_endpoint_mode" {
  description = "Kubeconfig endpoint mode. Use public_endpoint when cluster_api_host is set."
  type        = string
  default     = "public_ip"
}

variable "talosconfig_endpoints_mode" {
  description = "Talos API endpoint selection for talosconfig."
  type        = string
  default     = "public_ip"
}

variable "deploy_hcloud_ccm" {
  description = "Bootstrap Hetzner cloud-controller-manager."
  type        = bool
  default     = true
}

variable "deploy_cilium" {
  description = "Bootstrap Cilium CNI manifests."
  type        = bool
  default     = true
}

variable "deploy_prometheus_operator_crds" {
  description = "Bootstrap Prometheus Operator CRDs."
  type        = bool
  default     = true
}

variable "disable_arm" {
  description = "Disable arm image lookup/use."
  type        = bool
  default     = false
}

variable "disable_x86" {
  description = "Disable x86 image lookup/use."
  type        = bool
  default     = false
}

variable "talos_image_id_x86" {
  description = "Optional custom Talos x86 image ID."
  type        = string
  default     = null
}

variable "talos_image_id_arm" {
  description = "Optional custom Talos arm image ID."
  type        = string
  default     = null
}
