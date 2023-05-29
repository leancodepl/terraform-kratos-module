output "postgresql_provider_config" {
  value     = module.postgresql.postgresql_provider_config
  sensitive = true
}

output "kratos" {
  value = module.kratos
}
