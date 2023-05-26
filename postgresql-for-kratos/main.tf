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
  libpg_base_connection_string = "postgresql://${azurerm_postgresql_flexible_server.main.fqdn}/?sslmode=require"
  libpg_connection_strings     = { for key, db in var.databases : key => "postgresql://${urlencode(postgresql_role.roles[key].name)}:${urlencode(postgresql_role.roles[key].password)}@${azurerm_postgresql_flexible_server.main.fqdn}/${azurerm_postgresql_flexible_server_database.databases[key].name}?sslmode=verify-full" }

  ado_base_connection_string = "Host=${azurerm_postgresql_flexible_server.main.fqdn};SSL Mode=VerifyFull"
  ado_connection_strings     = { for key, db in var.databases : key => "${local.ado_base_connection_string};Database=${azurerm_postgresql_flexible_server_database.databases[key].name};Username=${postgresql_role.roles[key].name};Password='${postgresql_role.roles[key].password}'" }

  db_data = {
    for key, db in var.databases : key => {
      user     = postgresql_role.roles[key].name
      password = postgresql_role.roles[key].password
      host     = azurerm_postgresql_flexible_server.main.fqdn
      port     = 5432
      name     = key
    }
  }
}

output "id" {
  value = azurerm_postgresql_flexible_server.main.id
}

output "administrator_login" {
  value = azurerm_postgresql_flexible_server.main.administrator_login
}

output "administrator_password" {
  value     = random_password.administrator_password.result
  sensitive = true
}

output "libpg_base_connection_string" {
  value = local.libpg_base_connection_string
}

output "libpg_connection_strings" {
  value     = local.libpg_connection_strings
  sensitive = true
}

output "ado_connection_strings" {
  value     = local.ado_connection_strings
  sensitive = true
}

output "db_data" {
  value     = local.db_data
  sensitive = true
}
