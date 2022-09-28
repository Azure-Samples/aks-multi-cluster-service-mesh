resource "azurerm_log_analytics_workspace" "log_analytics_workspace_one" {
  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-workspace" : "${var.name_prefix}-${var.location_one}-workspace"
  location            = azurerm_resource_group.resource_group_one.location
  resource_group_name = var.location_one != var.location_two ? azurerm_resource_group.resource_group_one.name : azurerm_resource_group.resource_group_shared.name
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
  count = var.location_one != var.location_two ? 1 : 0

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

resource "azurerm_log_analytics_solution" "container_insights_solution_one" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.resource_group_one.location
  resource_group_name   = var.location_one != var.location_two ? azurerm_resource_group.resource_group_one.name : azurerm_resource_group.resource_group_shared.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace_one.name

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_log_analytics_solution" "container_insights_solution_two" {
  count = var.location_one != var.location_two ? 1 : 0

  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.resource_group_two.location
  resource_group_name   = azurerm_resource_group.resource_group_two.name
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace_two[0].id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace_two[0].name

  plan {
    product   = "OMSGallery/ContainerInsights"
    publisher = "Microsoft"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}