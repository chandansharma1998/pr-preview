output "namespace" { value = kubernetes_namespace.ns.metadata[0].name }
output "host"      { value = var.host }
