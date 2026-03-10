output "app_insights_connection_string" {
  description = "App Insights connection string passed to Function App as an app setting"
  value       = azurerm_application_insights.appinsights.connection_string
  sensitive   = true
}
output "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID"
  value       = azurerm_log_analytics_workspace.law.id
}
output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.law.name
}
output "action_group_id" {
  description = "Action group ID used by the alert rule in the environment config"
  value       = azurerm_monitor_action_group.alert_group.id
}
