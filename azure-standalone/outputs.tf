output "postgresql_provider_config" {
  value     = module.postgresql.postgresql_provider_config
  sensitive = true
}
