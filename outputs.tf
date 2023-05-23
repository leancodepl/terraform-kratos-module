output "external_ingress_url" {
  description = "Public URL for connecting to deployed Kratos instance from outside the cluster, if ingress_host was provided"
  value       = var.ingress_host == null ? null : "https://${var.ingress_host}"
}

output "internal_service_url" {
  description = "Cluster-private URLs for connecting to deployed Kratos instance, both public and admin API endpoints"
  value = {
    public = local.service_url
    admin  = "${local.service_url}:4434"
  }
}

output "service_name" {
  description = "Name of created Kubernetes service for use with other routing schemes"
  value       = kubernetes_service_v1.kratos_service.metadata[0].name
}
