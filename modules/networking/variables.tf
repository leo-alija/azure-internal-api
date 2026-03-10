variable "name_prefix" {
  description = "Prefix for all resource names in this module" # Prefix used for all resource names
  type        = string
}
variable "location" {
  description = "Azure region"
  type        = string
}

variable "address_space" {
  description = "VNET CIDR"
  type        = list(string) # We'll only use one (e.g. ["10.0.0.0/16"]) - Just better practice
}

variable "subnets" {
  description = "Map of subnet names to their config"
  type = map(object({
    address_prefix = string
  }))
}

variable "function_subnet_key" {
  description = "Key from the subnets map that the Function App will use"
  type        = string
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
