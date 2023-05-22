output "external_ingress_url" {
  value = var.ingress_host == null ? null : "https://${var.ingress_host}"
}

output "internal_service_url" {
  value = {
    public = local.service_url
    admin  = "${local.service_url}:4434"
  }
}

output "service_name" {
  value = kubernetes_service_v1.kratos_service.metadata[0].name
}
