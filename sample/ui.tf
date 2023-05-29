locals {
  labels_ui = {
    project   = var.project
    component = "kratos-ui"
  }
}

resource "kubernetes_deployment_v1" "kratos" {
  metadata {
    name      = "${var.project}-kratos-ui"
    namespace = kubernetes_namespace_v1.sample.metadata[0].name
    labels    = local.labels_ui
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels_ui
    }
    template {
      metadata {
        labels = local.labels_ui
      }
      spec {
        container {
          name  = "kratos-ui"
          image = "docker.io/oryd/kratos-selfservice-ui-node:v0.13.0"
          env {
            name  = "KRATOS_PUBLIC_URL"
            value = module.sample.kratos.internal_service_url.public
          }
          env {
            name  = "KRATOS_BROWSER_URL"
            value = module.sample.kratos.external_ingress_url
          }
          port {
            name           = "public"
            container_port = "3000"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "kratos_ui_service" {
  metadata {
    name      = "${var.project}-kratos-ui-svc"
    namespace = kubernetes_namespace_v1.sample.metadata[0].name
    labels    = local.labels_ui
  }
  spec {
    type     = "ClusterIP"
    selector = local.labels_ui
    port {
      name        = "public"
      port        = 80
      target_port = 3000
    }
  }
}

resource "kubernetes_ingress_v1" "kratos_ui_ingress" {
  metadata {
    name      = "${var.project}-kratos-ui-ingress"
    namespace = kubernetes_namespace_v1.sample.metadata[0].name
    labels    = local.labels_ui
  }
  spec {
    rule {
      host = var.domain
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.kratos_ui_service.metadata[0].name
              port {
                number = 80
              }
            }
          }
          path_type = "ImplementationSpecific"
        }
      }
    }
  }

  lifecycle {
    ignore_changes = [
      spec[0].ingress_class_name
    ]
  }
}
