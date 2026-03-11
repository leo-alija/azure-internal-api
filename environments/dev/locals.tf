# Central place for values shared across all module calls.
# Change name_prefix here and everything updates.

locals {
  name_prefix = "internalapi-dev"
  tags = {
    project     = "azure-internal-api"
    environment = "dev"
    managed_by  = "terraform"
  }
  subnets = {
    "function-integration" = {
      address_prefix = "10.0.1.0/24"
    }
    "private-endpoints" = {
      address_prefix = "10.0.2.0/24"
    }
  }
}
