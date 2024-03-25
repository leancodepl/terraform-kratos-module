resource "random_password" "kratos_cookie_secret" {
  length  = 64
  special = false
}

resource "random_password" "kratos_cipher_secret" {
  length  = 32
  special = false
}

resource "kubernetes_job_v1" "kratos_migrations" {
  metadata {
    name      = "${var.project}-kratos-migrations"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels_migrations
  }
  spec {
    template {
      metadata {
        labels = local.labels_migrations
      }
      spec {
        container {
          name  = "kratos-migrations"
          image = var.image
          args  = ["migrate", "sql", "--read-from-env", "--yes"]
          env_from {
            secret_ref {
              name = kubernetes_secret_v1.kratos_secret.metadata[0].name
            }
          }
          dynamic "env" {
            for_each = var.env

            content {
              name  = env.value.name
              value = env.value.value

              dynamic "value_from" {
                for_each = env.value.value_from[*]

                content {
                  dynamic "config_map_key_ref" {
                    for_each = value_from.value.config_map_key_ref[*]

                    content {
                      optional = config_map_key_ref.value.optional
                      name     = config_map_key_ref.value.name
                      key      = config_map_key_ref.value.key
                    }
                  }

                  dynamic "secret_key_ref" {
                    for_each = value_from.value.secret_key_ref[*]

                    content {
                      optional = secret_key_ref.value.optional
                      name     = secret_key_ref.value.name
                      key      = secret_key_ref.value.key
                    }
                  }

                  dynamic "field_ref" {
                    for_each = value_from.value.field_ref[*]

                    content {
                      api_version = field_ref.value.api_version
                      field_path  = field_ref.value.field_path
                    }
                  }

                  dynamic "resource_field_ref" {
                    for_each = value_from.value.resource_field_ref[*]

                    content {
                      container_name = resource_field_ref.value.container_name
                      divisor        = resource_field_ref.value.divisor
                      resource       = resource_field_ref.value.resource
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  wait_for_completion = true
}

resource "kubernetes_deployment_v1" "kratos" {
  metadata {
    name      = "${var.project}-kratos"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels
  }
  spec {
    replicas = local.run_courier_as_inproc_background_task ? 1 : var.replicas
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
        container {
          name  = "kratos"
          image = var.image
          args  = var.replicas < 1 ? ["serve", "--watch-courier", "-c", "/home/ory/.kratos.yaml"] : ["serve", "-c", "/home/ory/.kratos.yaml"]
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
          dynamic "env" {
            for_each = var.env

            content {
              name  = env.value.name
              value = env.value.value

              dynamic "value_from" {
                for_each = env.value.value_from[*]

                content {
                  dynamic "config_map_key_ref" {
                    for_each = value_from.value.config_map_key_ref[*]

                    content {
                      optional = config_map_key_ref.value.optional
                      name     = config_map_key_ref.value.name
                      key      = config_map_key_ref.value.key
                    }
                  }

                  dynamic "secret_key_ref" {
                    for_each = value_from.value.secret_key_ref[*]

                    content {
                      optional = secret_key_ref.value.optional
                      name     = secret_key_ref.value.name
                      key      = secret_key_ref.value.key
                    }
                  }

                  dynamic "field_ref" {
                    for_each = value_from.value.field_ref[*]

                    content {
                      api_version = field_ref.value.api_version
                      field_path  = field_ref.value.field_path
                    }
                  }

                  dynamic "resource_field_ref" {
                    for_each = value_from.value.resource_field_ref[*]

                    content {
                      container_name = resource_field_ref.value.container_name
                      divisor        = resource_field_ref.value.divisor
                      resource       = resource_field_ref.value.resource
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_job_v1.kratos_migrations]
}

resource "kubernetes_deployment_v1" "kratos_courier" {
  count = local.run_courier_as_inproc_background_task ? 0 : 1

  metadata {
    name      = "${var.project}-kratos-courier"
    namespace = data.kubernetes_namespace_v1.kratos_ns.metadata[0].name
    labels    = local.labels_courier
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels_courier
    }
    template {
      metadata {
        labels = local.labels_courier
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
        container {
          name  = "kratos-courier"
          image = var.image
          args  = ["courier", "watch", "-c", "/home/ory/.kratos.yaml"]
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
          resources {
            requests = var.courier_resources == null ? var.resources.requests : var.courier_resources.requests
            limits   = var.courier_resources == null ? var.resources.limits : var.courier_resources.limits
          }
          dynamic "env" {
            for_each = var.env

            content {
              name  = env.value.name
              value = env.value.value

              dynamic "value_from" {
                for_each = env.value.value_from[*]

                content {
                  dynamic "config_map_key_ref" {
                    for_each = value_from.value.config_map_key_ref[*]

                    content {
                      optional = config_map_key_ref.value.optional
                      name     = config_map_key_ref.value.name
                      key      = config_map_key_ref.value.key
                    }
                  }

                  dynamic "secret_key_ref" {
                    for_each = value_from.value.secret_key_ref[*]

                    content {
                      optional = secret_key_ref.value.optional
                      name     = secret_key_ref.value.name
                      key      = secret_key_ref.value.key
                    }
                  }

                  dynamic "field_ref" {
                    for_each = value_from.value.field_ref[*]

                    content {
                      api_version = field_ref.value.api_version
                      field_path  = field_ref.value.field_path
                    }
                  }

                  dynamic "resource_field_ref" {
                    for_each = value_from.value.resource_field_ref[*]

                    content {
                      container_name = resource_field_ref.value.container_name
                      divisor        = resource_field_ref.value.divisor
                      resource       = resource_field_ref.value.resource
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
  depends_on = [kubernetes_job_v1.kratos_migrations]
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
    "SERVE_ADMIN_BASE_URL"        = "${local.service_url}:4434/"
    "SERVE_PUBLIC_BASE_URL"       = var.ingress_host == null ? null : "https://${var.ingress_host}/"
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
