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

variable "cluster_api_host_private" {
  description = "Optional stable private DNS hostname for Kubernetes API endpoint."
  type        = string
  default     = null
}

variable "kubeconfig_endpoint_mode" {
  description = "Kubeconfig endpoint mode override. If null, auto-selects public_endpoint when gateway kube API exposure is enabled, otherwise private_ip."
  type        = string
  default     = null
}

variable "talosconfig_endpoints_mode" {
  description = "Talos API endpoint selection for talosconfig."
  type        = string
  default     = "private_ip"
}

variable "network_ipv4_cidr" {
  description = "Cluster network IPv4 CIDR."
  type        = string
  default     = "10.0.0.0/16"
}

variable "node_ipv4_cidr" {
  description = "Node subnet IPv4 CIDR."
  type        = string
  default     = "10.0.1.0/24"
}

variable "pod_ipv4_cidr" {
  description = "Pod network IPv4 CIDR."
  type        = string
  default     = "10.0.16.0/20"
}

variable "service_ipv4_cidr" {
  description = "Service network IPv4 CIDR."
  type        = string
  default     = "10.0.8.0/21"
}

variable "enable_gateway" {
  description = "Create a dedicated gateway VM with public IP and private NIC."
  type        = bool
  default     = true
}

variable "gateway_server_type" {
  description = "Hetzner server type for the gateway."
  type        = string
  default     = "cax11"
}

variable "gateway_image" {
  description = "OS image for the gateway VM."
  type        = string
  default     = "debian-13"
}

variable "gateway_private_ip" {
  description = "Optional fixed private IP for the gateway in node subnet."
  type        = string
  default     = null
}

variable "gateway_allowed_cidrs" {
  description = "Source CIDRs allowed to reach gateway exposed ports."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "expose_kube_api_via_gateway" {
  description = "Expose Kubernetes API (6443) on gateway."
  type        = bool
  default     = true
}

variable "expose_talos_api_via_gateway" {
  description = "Expose Talos API (50000) on gateway."
  type        = bool
  default     = true
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
