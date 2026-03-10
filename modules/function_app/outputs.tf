# The environment config and observability module need these.
# function_app_id goes to the alert rule, the rest are useful for reference.

output "function_app_id" {
  description = "Function App resource ID - the alert rule targets this"
  value       = azurerm_linux_function_app.func.id
}

output "function_app_name" {
  description = "Function App name - used for code deployment"
  value       = azurerm_linux_function_app.func.name
}

output "function_app_default_hostname" {
  description = "Function App hostname - only resolves via PE inside the VNet"
  value       = azurerm_linux_function_app.func.default_hostname
}

output "storage_account_name" {
  description = "Storage account name used by the Function App"
  value       = azurerm_storage_account.func_sa.name
}
