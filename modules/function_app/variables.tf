variable "name_prefix" {
  description = "Prefix for all resource names in this module"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "function_subnet_id" {
  description = "Subnet ID for VNet integration, Function App outbound traffic"
  type        = string
}

variable "pe_subnet_id" {
  description = "Subnet ID where all private endpoints will live"
  type        = string
}

# DNS zones for the private endpoints. These let the Function App resolve storage and Key Vault endpoints to their private IPs instead of public ones.
variable "function_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.azurewebsites.net"
  type        = string
}

variable "blob_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.blob.core.windows.net"
  type        = string
}

variable "queue_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.queue.core.windows.net"
  type        = string
}

variable "table_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.table.core.windows.net"
  type        = string
}

variable "file_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.file.core.windows.net"
  type        = string
}


variable "key_vault_id" {
  description = "Key Vault resource ID - used to set up RBAC for the Function's managed identity"
  type        = string
}

variable "key_vault_uri" {
  description = "Key Vault URI - passed as an app setting so the function knows where to find certs"
  type        = string
}

# Observability inputs

variable "app_insights_connection_string" {
  description = "Application Insights connection string - the SDK picks this up automatically"
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
