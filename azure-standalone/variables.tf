variable "postgresql" {
  type = object({
    resource_group_name = string
    server = object({
      name                = string
      version             = string
      sku_name            = string
      storage_mb          = number
      administrator_login = string
      tags                = map(string)
    })
    ad_admin = object({
      tenant_id      = string
      object_id      = string
      principal_name = string
      principal_type = string
    })
    firewall = object({
      allow_all         = bool
      allowed_k8s_ip    = string
      allowed_office_ip = string
    })
  })
}

variable "kratos" {
  type = object({
    namespace    = string
    project      = string
    ingress_host = string
    labels       = map(string)
    image        = string
    replicas     = number

    resources = object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })

    courier_resources = object({
      requests = object({
        cpu    = string
        memory = string
      })
      limits = object({
        cpu    = string
        memory = string
      })
    })

    config_files = map(string)
    config_yaml  = string

    courier_smtp_connection_uri = string
  })
}
