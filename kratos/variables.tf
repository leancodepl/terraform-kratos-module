variable "namespace" {
  type        = string
  description = "Kubernetes namespace to deploy to"
  nullable    = false
}

variable "project" {
  type        = string
  description = "Project name to used as label and prefix for created resources"
  nullable    = false
}

variable "ingress_host" {
  type        = string
  description = "Create an ingress to expose public Kratos endpoint under this hostname if provided"
  nullable    = true
}

variable "labels" {
  type        = map(string)
  description = "Kubernetes labels to attach to created resources"
  default     = {}
  nullable    = false
}

variable "image" {
  type        = string
  description = "Image repository and version to use for deployment"
  default     = "docker.io/oryd/kratos:v1.0.0"
  nullable    = false
}

variable "replicas" {
  type        = number
  description = "Number of main Kratos pod replicas, must be a positive integer"
  default     = 1
  nullable    = false

  validation {
    condition     = can(parseint(tostring(var.replicas), 10))
    error_message = "The replicas value must be an integer."
  }

  validation {
    condition     = var.replicas >= 1
    error_message = "The replicas value must be positive."
  }
}

variable "courier_mode" {
  type        = string
  description = "Message courier deployment mode, one of: \"disabled\", \"background\", \"standalone\""
  nullable    = false

  validation {
    condition     = contains(["disabled", "background", "standalone"], var.courier_mode)
    error_message = "The value of courier_mode must be one of: \"disabled\", \"background\", \"standalone\"."
  }

  validation {
    condition     = var.courier_mode != "background" || var.replicas == 1
    error_message = "The value of replicas must be 1 to enable message courier as a background task on the sole Kratos pod."
  }
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
  description = "Resource requests and limits for main Kratos pods"
  nullable    = false
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
  description = "Resource requests and limits for courier Kratos pod"
  nullable    = true
}

variable "config_files" {
  type        = map(string)
  description = "Additional files to be mounted at /etc/kratos, e.g. identity schemas and courier templates"
  default     = {}
  nullable    = false
}

variable "config_yaml" {
  type        = string
  description = "Content of kratos.yaml configuration file"
  sensitive   = true # may contain webhook secrets
  nullable    = false
}

variable "dsn" {
  type        = string
  description = "Data source name, database connection data and credentials in URI form, e.g. postgresql://kratos:correct%20horse%20battery%20staple@postgresd:5432/kratosdb?sslmode=require&max_conns=20&max_idle_conns=4"
  sensitive   = true
  nullable    = false
}

variable "courier_smtp_connection_uri" {
  type        = string
  description = "SMTP connection data and credentials in URI form for email delivery, e.g. smtps://apikey:SG.myapikey@smtp.sendgrid.net:465"
  sensitive   = true
  nullable    = false
}

variable "cookie_secret" {
  type        = string
  description = "External cookie secret to import and use instead of generating one, must be at least 16 characters long"
  sensitive   = true
  nullable    = true
  default     = null

  validation {
    condition     = var.cookie_secret == null || length(var.cookie_secret) >= 16
    error_message = "The value of cookie_secret must be at least 16 characters long."
  }
}

variable "cipher_secret" {
  type        = string
  description = "External cipher secret to import and use instead of generating one, must be exactly 32 characters long"
  sensitive   = true
  nullable    = true
  default     = null

  validation {
    condition     = var.cipher_secret == null || length(var.cipher_secret) == 32
    error_message = "The value of cipher_secret must be exactly 32 characters long."
  }
}

variable "env" {
  type = list(object({
    name  = string
    value = optional(string)
    value_from = optional(object({
      config_map_key_ref = optional(object({
        optional = bool
        name     = string
        key      = string
      }))
      secret_key_ref = optional(object({
        optional = bool
        name     = string
        key      = string
      }))
      field_ref = optional(object({
        api_version = string
        field_path  = string
      }))
      resource_field_ref = optional(object({
        container_name = string
        divisor        = string
        resource       = string
      }))
    }))
  }))
  description = "A list of additional environment variables that will be passed as the `env` block in pods"
  sensitive   = false
  nullable    = false
  default     = []
}
