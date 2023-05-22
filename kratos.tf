resource "random_password" "kratos_cookie_secret" {
  length  = 64
  special = false
}

resource "random_password" "kratos_cipher_secret" {
  length  = 32
  special = false
}

resource "kubernetes_deployment_v1" "kratos_deployment" {
  metadata {
    name      = "${var.project}-kratos"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }
  spec {
    replicas = 1 # increasing number of replicas would require extracting courier to its own pod
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        labels = local.labels
      }
      spec {
        volume {
          name = "config-files"
          config_map {
            name = kubernetes_config_map_v1.kratos_config_files.metadata[0].name
          }
        }
        volume {
          name = "config-yaml"
          secret {
            secret_name = kubernetes_secret_v1.kratos_config_yaml.metadata[0].name
          }
        }
        init_container {
          name  = "kratos-migrate"
          image = var.image
          args  = ["migrate", "sql", "--read-from-env", "--yes"]
          volume_mount {
            name       = "config-files"
            mount_path = "/etc/kratos"
            read_only  = true
          }
          volume_mount {
            name       = "config-yaml"
            sub_path   = ".kratos.yaml"
            mount_path = "/home/ory/.kratos.yaml"
            read_only  = true
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.kratos_secret.metadata[0].name
            }
          }
        }
        container {
          name  = "kratos"
          image = var.image
          args  = ["serve", "--watch-courier"]
          volume_mount {
            name       = "config-files"
            mount_path = "/etc/kratos"
            read_only  = true
          }
          volume_mount {
            name       = "config-yaml"
            sub_path   = ".kratos.yaml"
            mount_path = "/home/ory/.kratos.yaml"
            read_only  = true
          }
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.kratos_secret.metadata[0].name
            }
          }
          port {
            name           = "public"
            container_port = "4433"
          }
          port {
            name           = "admin"
            container_port = "4434"
          }
          resources {
            requests = var.resources.requests
            limits   = var.resources.limits
          }
          liveness_probe {
            http_get {
              path = "/health/alive"
              port = "public"
            }
          }
          readiness_probe {
            http_get {
              path = "/health/ready"
              port = "public"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_config_map_v1" "kratos_config_files" {
  metadata {
    name      = "${var.project}-kratos-config-files"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }

  data = var.config_files
}

resource "kubernetes_secret_v1" "kratos_config_yaml" {
  metadata {
    name      = "${var.project}-kratos-config-yaml"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }

  data = {
    ".kratos.yaml" = var.config_yaml
  }
}

resource "kubernetes_secret_v1" "kratos_secret" {
  metadata {
    name      = "${var.project}-kratos-secret"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }

  data = {
    "DSN"                         = var.dsn
    "COURIER_SMTP_CONNECTION_URI" = var.courier_smtp_connection_uri
    "SECRETS_COOKIE"              = random_password.kratos_cookie_secret.result
    "SECRETS_CIPHER"              = random_password.kratos_cipher_secret.result
  }
}

resource "kubernetes_service_v1" "kratos_service" {
  metadata {
    name      = "${var.project}-kratos-svc"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }
  spec {
    type     = "ClusterIP"
    selector = local.labels
    port {
      name        = "public"
      port        = 80
      target_port = 4433
    }
    port {
      name        = "admin"
      port        = 4434
      target_port = 4434
    }
  }
}

resource "kubernetes_ingress_v1" "kratos_ingress" {
  count = var.ingress_host == null ? 0 : 1
  metadata {
    name      = "${var.project}-kratos-ingress"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }
  spec {
    rule {
      host = var.ingress_host
      http {
        path {
          backend {
            service {
              name = kubernetes_service_v1.kratos_service.metadata[0].name
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

locals {
  service_url = "http://${kubernetes_service_v1.kratos_service.metadata[0].name}.${kubernetes_service_v1.kratos_service.metadata[0].namespace}.svc.cluster.local"
}
