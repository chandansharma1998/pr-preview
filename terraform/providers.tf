terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.29"
    }
  }
  required_version = ">= 1.5.0"
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}
