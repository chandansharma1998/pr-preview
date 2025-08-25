locals {
  name      = "pr-${var.pr_number}"
  namespace = local.name
  labels    = { app = local.name }
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = local.namespace
    labels = local.labels
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels    = local.labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        container {
          name  = "app"
          image = var.image
          port {
            container_port = 3000
          }
          env {
            name  = "PR_NUMBER"
            value = var.pr_number
          }
          readiness_probe {
            http_get {
              path = "/"
              port = 3000
            }
            initial_delay_seconds = 3
            period_seconds        = 5
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "svc" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.ns.metadata[0].name
    labels    = local.labels
  }
  spec {
    selector = local.labels
    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress_v1" "ing" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
    labels = local.labels
  }
  spec {
    rule {
      host = var.host
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.svc.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}
