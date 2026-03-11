output "resource_group_name" {
  description = "Resource group name"
  value       = module.networking.resource_group_name
}

output "function_app_name" {
  description = "Function App name"
  value       = module.function_app.function_app_name
}

output "function_app_hostname" {
  description = "Function App hostname which only resolves inside the VNet"
  value       = module.function_app.function_app_default_hostname
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = module.key_vault_certs.key_vault_name
}

output "storage_account_name" {
  description = "Storage account name"
  value       = module.function_app.storage_account_name
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = module.observability.log_analytics_workspace_name
}
