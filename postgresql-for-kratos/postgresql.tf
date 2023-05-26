provider "postgresql" {
  host      = azurerm_postgresql_flexible_server.main.fqdn
  database  = "postgres"
  username  = var.server.administrator_login
  password  = random_password.administrator_password.result
  superuser = false
  sslmode   = "verify-full"
}

resource "postgresql_role" "roles" {
  for_each = var.databases

  name     = each.key
  password = random_password.role_passwords[each.key].result
  login    = true
}

resource "postgresql_grant" "role_database_access" {
  for_each = var.databases

  database    = azurerm_postgresql_flexible_server_database.databases[each.key].name
  role        = postgresql_role.roles[each.key].name
  object_type = "database"
  privileges  = ["CREATE"]
}
