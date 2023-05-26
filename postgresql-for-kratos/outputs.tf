output "postgresql_provider_config" {
  value = {
    host      = azurerm_postgresql_flexible_server.main.fqdn
    database  = "postgres"
    username  = var.server.administrator_login
    password  = random_password.administrator_password.result
    superuser = false
    sslmode   = "verify-full"
  }
  depends_on = [azurerm_postgresql_flexible_server_firewall_rule.allow_office]
  sensitive  = true
}

output "libpg_connection_strings" {
  value     = local.libpg_connection_strings
  sensitive = true
}
