terraform {
  required_version = ">= 1.4"
}

module "postgresql" {
  source = "../postgresql-for-kratos"

  resource_group_name = var.postgresql.resource_group_name
  server              = var.postgresql.server
  ad_admin            = var.postgresql.ad_admin
  firewall            = var.postgresql.firewall

  databases = {
    "kratos" = {
      charset   = "UTF8"
      collation = "en_US.utf8"
    }
  }
}

module "kratos" {
  source = "../kratos"

  namespace    = var.kratos.namespace
  project      = var.kratos.project
  ingress_host = var.kratos.ingress_host
  labels       = var.kratos.labels
  image        = var.kratos.image
  replicas     = var.kratos.replicas

  resources         = var.kratos.resources
  courier_resources = var.kratos.courier_resources

  config_files = var.kratos.config_files
  config_yaml  = var.kratos.config_yaml

  courier_smtp_connection_uri = var.kratos.courier_smtp_connection_uri

  dsn = module.postgresql.libpg_connection_strings["kratos"]
}
