resource "azurerm_log_analytics_workspace" "log_analytics_workspace_one" {
  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-workspace" : "${var.name_prefix}-${var.location_one}-workspace"
  location            = azurerm_resource_group.resource_group_one.location
  resource_group_name = azurerm_resource_group.resource_group_one.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_worspace_retention_days
  tags                = var.tags

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_workspace_two" {
  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}-workspace" : "${var.name_prefix}-${var.location_two}-workspace"
  location            = azurerm_resource_group.resource_group_two.location
  resource_group_name = azurerm_resource_group.resource_group_two.name
  sku                 = var.log_analytics_workspace_sku
  retention_in_days   = var.log_analytics_worspace_retention_days
  tags                = var.tags

  lifecycle {
    ignore_changes = [
        tags
    ]
  }
}