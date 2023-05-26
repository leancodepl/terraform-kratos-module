terraform {
  required_version = ">= 1.4"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.57"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.19"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

data "azurerm_resource_group" "postgresql" {
  name = var.resource_group_name
}

locals {
  libpg_connection_strings     = { for key, db in var.databases : key => "postgresql://${urlencode(postgresql_role.roles[key].name)}:${urlencode(postgresql_role.roles[key].password)}@${azurerm_postgresql_flexible_server.main.fqdn}/${azurerm_postgresql_flexible_server_database.databases[key].name}?sslmode=verify-full" }
}

output "libpg_connection_strings" {
  value     = local.libpg_connection_strings
  sensitive = true
}
