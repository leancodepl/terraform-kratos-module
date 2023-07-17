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
  description = "Number of main Kratos pod replicas, special value of 0 is treated as 1 but also disables separate courier pod"
  default     = 1
  nullable    = false
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
