variable "pr_number" {
  description = "Pull Request number"
  type        = string
}

variable "image" {
  description = "Docker image (tagged with pr_number)"
  type        = string
}

variable "host" {
  description = "Ingress host (e.g., pr-123.192.168.49.2.nip.io)"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig"
  type        = string
  default     = "~/.kube/config"
}
