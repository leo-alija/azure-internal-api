# Dev environment - All modules into one

module "networking" {
  source              = "../../modules/networking"
  name_prefix         = local.name_prefix
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  subnets             = local.subnets
  function_subnet_key = "function-integration"
  tags                = local.tags
}

module "key_vault_certs" {
  source               = "../../modules/key_vault_certs"
  name_prefix          = local.name_prefix
  location             = var.location
  resource_group_name  = module.networking.resource_group_name
  pe_subnet_id         = module.networking.subnet_ids["private-endpoints"]
  keyvault_dns_zone_id = module.networking.private_dns_zone_ids["keyvault"]
  tags                 = local.tags
}

module "observability" {
  source              = "../../modules/observability"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = module.networking.resource_group_name
  alert_email         = var.alert_email
  log_retention_days  = 30
  tags                = local.tags
}

module "function_app" {
  source              = "../../modules/function_app"
  name_prefix         = local.name_prefix
  location            = var.location
  resource_group_name = module.networking.resource_group_name

  # Networking
  function_subnet_id   = module.networking.subnet_ids["function-integration"]
  pe_subnet_id         = module.networking.subnet_ids["private-endpoints"]
  function_dns_zone_id = module.networking.private_dns_zone_ids["function"]
  blob_dns_zone_id     = module.networking.private_dns_zone_ids["blob"]
  queue_dns_zone_id    = module.networking.private_dns_zone_ids["queue"]
  table_dns_zone_id    = module.networking.private_dns_zone_ids["table"]
  file_dns_zone_id     = module.networking.private_dns_zone_ids["file"]
  # Key Vault
  key_vault_id  = module.key_vault_certs.key_vault_id
  key_vault_uri = module.key_vault_certs.key_vault_uri
  # Observability
  app_insights_connection_string = module.observability.app_insights_connection_string
  tags                           = local.tags
}

