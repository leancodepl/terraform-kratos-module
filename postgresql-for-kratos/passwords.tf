resource "random_password" "administrator_password" {
  length  = 64
  special = false
}

resource "random_password" "role_passwords" {
  for_each = var.databases

  length  = 64
  special = false
}
