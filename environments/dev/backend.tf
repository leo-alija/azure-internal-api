# Keeping state local for the assessment
# In a real environment, I'd use an Azure Storage Account backend for remote state management.
# That storage account would be created first as a separate bootstrap step
# then I'd configure the backend to use it as shown below (uncommented)
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "stterraformstate01"
#     container_name       = "tfstate"
#     key                  = "dev.terraform.tfstate"
#   }
# }
