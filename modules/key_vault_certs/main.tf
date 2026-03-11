# Key Vault RBAC + Certificates module 

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "kv" {
  name                          = "kv-${replace(var.name_prefix, "-", "")}01"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  public_network_access_enabled = false
  soft_delete_retention_days    = 7 # Can be increased depending on feasibility
  purge_protection_enabled      = false
  network_acls {
    bypass         = "AzureServices" # Allows Function App MI through, but blocks all other public access
    default_action = "Deny"
  }
  tags = var.tags
}

resource "azurerm_role_assignment" "deploy_kv_admin" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Administrator" # Needed to create secrets
  principal_id         = data.azurerm_client_config.current.object_id
}
resource "azurerm_private_endpoint" "kv" {
  name                = "pe-kv-${var.name_prefix}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.pe_subnet_id
  tags                = var.tags
  private_service_connection {
    name                           = "psc-kv-${var.name_prefix}"
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
  private_dns_zone_group {
    name                 = "dns-kv-${var.name_prefix}"
    private_dns_zone_ids = [var.keyvault_dns_zone_id]
  }
}

# Creating a Certificate Authority 
resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Client cert signed by that CA 
resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem
  subject {
    common_name  = "ca.${var.name_prefix}.internal"
    organization = "Internal API CA"
  }
  validity_period_hours = 8760 # 1 year
  is_ca_certificate     = true
  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

resource "tls_private_key" "client" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "client" {
  private_key_pem = tls_private_key.client.private_key_pem

  subject {
    common_name  = "client.${var.name_prefix}.internal"
    organization = "Internal API Client"
  }
}

resource "tls_locally_signed_cert" "client" {
  cert_request_pem   = tls_cert_request.client.cert_request_pem
  ca_private_key_pem = tls_private_key.ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.ca.cert_pem

  validity_period_hours = 4380 # 6 months, shorter than the CA on purpose

  allowed_uses = [
    "client_auth",
    "digital_signature",
  ]
}

resource "azurerm_key_vault_secret" "ca_cert" {
  name         = "ca-certificate"
  value        = tls_self_signed_cert.ca.cert_pem
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "application/x-pem-file"
  tags         = var.tags

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "client_cert" {
  name         = "client-certificate"
  value        = tls_locally_signed_cert.client.cert_pem
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "application/x-pem-file"
  tags         = var.tags

  depends_on = [azurerm_role_assignment.kv_admin]
}

resource "azurerm_key_vault_secret" "client_key" {
  name         = "client-private-key"
  value        = tls_private_key.client.private_key_pem
  key_vault_id = azurerm_key_vault.kv.id
  content_type = "application/x-pem-file"
  tags         = var.tags

  depends_on = [azurerm_role_assignment.kv_admin]
}
