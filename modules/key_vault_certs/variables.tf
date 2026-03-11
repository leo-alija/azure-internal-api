variable "name_prefix" {
  description = "Prefix for all resource names in this module"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name created by the networking module"
  type        = string
}

variable "pe_subnet_id" {
  description = "Subnet ID where the Key Vault private endpoint will live"
  type        = string
}

variable "keyvault_dns_zone_id" {
  description = "Private DNS zone ID for privatelink.vaultcore.azure.net"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
