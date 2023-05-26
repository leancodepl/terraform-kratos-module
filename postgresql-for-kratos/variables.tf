variable "resource_group_name" {
  type     = string
  nullable = false
}

variable "server" {
  type = object({
    name                = string
    version             = string
    sku_name            = string
    storage_mb          = number
    administrator_login = string
    tags                = map(string)
  })
  nullable = false
}

variable "ad_admin" {
  type = object({
    tenant_id      = string
    object_id      = string
    principal_name = string
    principal_type = string
  })
  nullable = true
}

variable "databases" {
  type = map(object({
    charset   = string
    collation = string
  }))
  nullable = false
}

variable "firewall" {
  type = object({
    allow_all         = bool
    allowed_k8s_ip    = string
    allowed_office_ip = string
  })
  nullable = false
}
