output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.kv.name
}
output "key_vault_id" {
  description = "Key Vault resource ID for RBAC assignments"
  value       = azurerm_key_vault.kv.id
}
output "key_vault_uri" {
  description = "The Function App uses this to read secrets at runtime"
  value       = azurerm_key_vault.kv.vault_uri
}
