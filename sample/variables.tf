variable "azure" {
  type = object({
    tenant_id       = string
    subscription_id = string
  })
}

variable "kubernetes" {
  type = object({
    egress_ip              = string
    host                   = string
    config_context         = string
    config_context_cluster = string
    cluster_ca_certificate = string
  })
}

variable "project" {
  type = string
}

variable "location" {
  type = string
}

variable "domain" {
  type = string
}

variable "office_ip" {
  type = string
}

variable "sendgrid_api_key" {
  type = string
}

variable "oidc_config" {
  type = object({
    apple = object({
      client_id      = string
      team_id        = string
      private_key_id = string
      private_key    = string
    })
    google = object({
      client_id     = string
      client_secret = string
    })
    facebook = object({
      client_id     = string
      client_secret = string
    })
  })
}
