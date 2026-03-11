output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.rg.location
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}
output "subnet_ids" {
  description = "Map of subnet keys to their resource IDs"
  value       = { for k, v in azurerm_subnet.subnet : k => v.id }
}

output "nsg_ids" {
  description = "Map of subnet keys to their NSG resource IDs"
  value       = { for k, v in azurerm_network_security_group.nsg : k => v.id }
}

output "private_dns_zone_ids" {
  description = "Map of DNS zone keys to their resource IDs"
  value       = { for k, v in azurerm_private_dns_zone.dns : k => v.id }
}
