resource "azurerm_postgresql_flexible_server" "main" {
  resource_group_name = data.azurerm_resource_group.postgresql.name
  location            = data.azurerm_resource_group.postgresql.location

  name                   = var.server.name
  version                = var.server.version
  sku_name               = var.server.sku_name
  storage_mb             = var.server.storage_mb
  administrator_login    = var.server.administrator_login
  administrator_password = random_password.administrator_password.result

  create_mode = "Default"

  tags = var.server.tags

  authentication {
    password_auth_enabled         = true
    active_directory_auth_enabled = true
    tenant_id                     = var.ad_admin == null ? null : var.ad_admin.tenant_id
  }

  maintenance_window {
    start_hour = 3
  }

  lifecycle {
    ignore_changes = [zone]
  }
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "ad_admin" {
  count = var.ad_admin == null ? 0 : 1

  resource_group_name = azurerm_postgresql_flexible_server.main.resource_group_name
  server_name         = azurerm_postgresql_flexible_server.main.name

  tenant_id      = var.ad_admin.tenant_id
  object_id      = var.ad_admin.object_id
  principal_name = var.ad_admin.principal_name
  principal_type = var.ad_admin.principal_type
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  count = var.firewall.allow_all ? 1 : 0

  server_id = azurerm_postgresql_flexible_server.main.id
  name      = "allow-all"

  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_k8s" {
  count = var.firewall.allowed_k8s_ip == null ? 0 : 1

  server_id = azurerm_postgresql_flexible_server.main.id
  name      = "allow-k8s"

  start_ip_address = var.firewall.allowed_k8s_ip
  end_ip_address   = var.firewall.allowed_k8s_ip
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_office" {
  count = var.firewall.allowed_office_ip == null ? 0 : 1

  server_id = azurerm_postgresql_flexible_server.main.id
  name      = "allow-office"

  start_ip_address = var.firewall.allowed_office_ip
  end_ip_address   = var.firewall.allowed_office_ip
}

resource "azurerm_postgresql_flexible_server_database" "databases" {
  for_each = var.databases

  server_id = azurerm_postgresql_flexible_server.main.id

  name      = each.key
  charset   = each.value.charset
  collation = each.value.collation
}
