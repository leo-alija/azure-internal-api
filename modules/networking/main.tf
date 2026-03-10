# Networking module
# These modules create: resource groups, VNets, subnets, NSGs, private DNS zone and DNS-to-VNet links.

# Private DNS zones we need for private endpoints.
locals {
  private_dns_zones = {
    function = "privatelink.azurewebsites.net"
    keyvault = "privatelink.vaultcore.azure.net"
    blob     = "privatelink.blob.core.windows.net"
    queue    = "privatelink.queue.core.windows.net"
    table    = "privatelink.table.core.windows.net"
    file     = "privatelink.file.core.windows.net"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.name_prefix}"
  location = var.location
  tags     = var.tags
}
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
  tags                = var.tags
}
resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                              = "snet-${each.key}-${var.name_prefix}"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = [each.value.address_prefix]
  private_endpoint_network_policies = each.key == var.function_subnet_key ? "Enabled" : "Disabled"

  dynamic "delegation" {
    for_each = each.key == var.function_subnet_key ? [1] : []
    content {
      name = "function-delegation"
      service_delegation {
        name    = "Microsoft.Web/serverFarms" # Microsoft.Web/serverFarms delegation so the Function App can be injected into the VNet
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
      }
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  for_each = var.subnets

  name                = "nsg-${each.key}-${var.name_prefix}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags

  security_rule {
    name                       = "AllowVNet443Inbound" # Allow HTTPS (443) from within the VNet (internal API traffic)
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  security_rule {
    name                       = "AllowAzureLBInbound" # Allow Azure Load Balancer probes (needed for PE health checks)
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  for_each = var.subnets

  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

resource "azurerm_private_dns_zone" "dns" {
  for_each            = local.private_dns_zones # One zone per service. These let private endpoints resolve to their private IPs instead of public ones.
  name                = each.value
  resource_group_name = azurerm_resource_group.rg.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_link" {
  for_each              = local.private_dns_zones
  name                  = "link-${each.key}-${var.name_prefix}" # Link the DNS zone to the VNet
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns[each.key].name
  virtual_network_id    = azurerm_virtual_network.vnet.id
  registration_enabled  = false
  tags                  = var.tags
}
