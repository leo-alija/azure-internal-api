# Function App module


# The Function App runtime needs storage for: Function code (blob), Trigger bindings and scale coordination (queue), 
# Lease management (table), Deployment packages (file shares)

resource "azurerm_storage_account" "func_sa" {
  name                          = "st${replace(var.name_prefix, "-", "")}01"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  account_tier                  = "Standard"
  account_replication_type      = "LRS" # Locally redundant - ZRS for prod.
  public_network_access_enabled = false # No public access
  network_rules {
    bypass         = ["AzureServices"] # Block all access by default, even from Azure services
    default_action = "Deny"
  }
  tags = var.tags
}

# One Private Endpoint per storage subresource
locals {
  storage_subresources = {
    blob  = var.blob_dns_zone_id
    queue = var.queue_dns_zone_id
    table = var.table_dns_zone_id
    file  = var.file_dns_zone_id
  }
}
resource "azurerm_private_endpoint" "storage" {
  for_each = local.storage_subresources

  name                = "pe-st-${each.key}-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-st-${each.key}-${var.name_prefix}"
    private_connection_resource_id = azurerm_storage_account.func_sa.id
    is_manual_connection           = false
    subresource_names              = [each.key]
  }
  private_dns_zone_group {
    name                 = "dns-st-${each.key}-${var.name_prefix}"
    private_dns_zone_ids = [each.value]
  }
}

resource "azurerm_service_plan" "plan" {
  name                = "asp-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = "Y1" # pay per execution
  tags                = var.tags
}

# Python API will run on here.
resource "azurerm_linux_function_app" "func" {
  name                          = "func-${var.name_prefix}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  service_plan_id               = azurerm_service_plan.plan.id
  storage_account_name          = azurerm_storage_account.func_sa.name
  storage_account_access_key    = azurerm_storage_account.func_sa.primary_access_key
  virtual_network_subnet_id     = var.function_subnet_id
  public_network_access_enabled = false
  client_certificate_mode       = "Required" # mTLS - require a client certificate on every request
  client_certificate_enabled    = true       # That a cert is PRESENT, but doesn't validate
  identity {
    type = "SystemAssigned" # No passwords, Azure handles the auth.
  }
  site_config {
    vnet_route_all_enabled = true
    application_stack {
      python_version = "3.11"
    }
    ftps_state = "Disabled" # HTTPS only, disabling unencrypted traffic
  }
  app_settings = {
    # App Insights - the Python SDK picks this up automatically
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = var.app_insights_connection_string
    # Key Vault URI - our function code uses this to know where to find the CA cert
    "KEY_VAULT_URI" = var.key_vault_uri
    # Force all outbound through VNet
    "WEBSITE_VNET_ROUTE_ALL" = "1"
    # Tell the runtime to resolve storage via private DNS
    "WEBSITE_CONTENTOVERVNET" = "1"
  }
  tags       = var.tags
  depends_on = [azurerm_private_endpoint.storage] # Storage PEs must exist before the function can reach storage
}

# Function App Private Endpoint - This is how internal clients REACH the Function App.
# Without this, the function would only be accessible via its public URL (which we've disabled).
resource "azurerm_private_endpoint" "func" {
  name                = "pe-func-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-func-${var.name_prefix}"
    private_connection_resource_id = azurerm_linux_function_app.func.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
  private_dns_zone_group {
    name                 = "dns-func-${var.name_prefix}"
    private_dns_zone_ids = [var.function_dns_zone_id]
  }
}
# RBAC Configuration - Function App: The function's managed identity needs to READ secrets from Key Vault to get the CA certificate for mTLS validation.
resource "azurerm_role_assignment" "func_kv_secrets" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User" # least-privilege role, it can only read secret values
  principal_id         = azurerm_linux_function_app.func.identity[0].principal_id
}
