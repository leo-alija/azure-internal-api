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

variable "alert_email" {
  description = "Email address that receives alert notifications"
  type        = string
}

variable "log_retention_days" {
  description = "How many days to keep logs | 30 for dev, 90 for prod"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags applied to every resource in this module"
  type        = map(string)
  default     = {}
}
