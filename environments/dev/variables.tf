variable "location" {
  description = "Azure region for all resources"
  type        = string
  default     = "uksouth"
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}
