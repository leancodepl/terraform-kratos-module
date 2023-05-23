variable "namespace" {
  type     = string
  nullable = false
}

variable "project" {
  type     = string
  nullable = false
}

variable "ingress_host" {
  type     = string
  nullable = true
}

variable "labels" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "image" {
  type     = string
  default  = "docker.io/oryd/kratos:v0.13.0"
  nullable = false
}

variable "replicas" {
  type     = number
  default  = 1
  nullable = false
}

variable "resources" {
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  nullable = false
}

variable "courier_resources" {
  type = object({
    requests = object({
      cpu    = string
      memory = string
    })
    limits = object({
      cpu    = string
      memory = string
    })
  })
  nullable = true
}

variable "config_files" {
  type     = map(string)
  default  = {}
  nullable = false
}

variable "config_yaml" {
  type      = string
  sensitive = true # may contain webhook secrets
  nullable  = false
}

variable "dsn" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "courier_smtp_connection_uri" {
  type      = string
  sensitive = true
  nullable  = true
}
