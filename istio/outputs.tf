output "random_prefix" {
  value       = random_string.random.result
  description = "Specifies the random value that is used as a prefix for the name of all the Azure resources when not explicitly defined in variables."
}

output "log_analytics_workspace_id" {
  value = var.location_one != var.location_two ? azurerm_log_analytics_workspace.log_analytics_workspace_two[0].id : azurerm_log_analytics_workspace.log_analytics_workspace_one.id
}

output "log_analytics_workspace_name" {
  value = var.location_one != var.location_two ? azurerm_log_analytics_workspace.log_analytics_workspace_two[0].name : azurerm_log_analytics_workspace.log_analytics_workspace_one.name
}