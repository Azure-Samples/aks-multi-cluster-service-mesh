
resource "azurerm_user_assigned_identity" "container_registry_identity" {
  resource_group_name = azurerm_resource_group.resource_group_shared.name
  location            = var.location_one
  tags                = var.tags

  name = var.name_prefix == null ? "${random_string.random.result}-acr-identity" : "${var.name_prefix}-acr-identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_container_registry" "container_registry" {
  name                = var.name_prefix == null ? "${random_string.random.result}acr" : "${var.name_prefix}acr"
  resource_group_name = azurerm_resource_group.resource_group_shared.name
  location            = azurerm_resource_group.resource_group_shared.location
  sku                 = var.acr_sku
  tags                = var.tags

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.container_registry_identity.id
    ]
  }

  dynamic "georeplications" {
    for_each = [var.location_two]

    content {
      location = georeplications.value
      tags     = var.tags
    }
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "acrpull_assignment_aks_one_kubelet_identity" {
  principal_id                     = module.aks_one.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.container_registry.id
  skip_service_principal_aad_check = true
  depends_on                       = [module.aks_one]
}

resource "azurerm_role_assignment" "acrpull_assignment_aks_two_kubelet_identity" {
  principal_id                     = module.aks_two.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.container_registry.id
  skip_service_principal_aad_check = true
  depends_on                       = [module.aks_two]
}

resource "azurerm_monitor_diagnostic_setting" "registry_diagnostics_settings" {
  name                       = "diagnostics-settings"
  target_resource_id         = azurerm_container_registry.container_registry.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id

  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "ContainerRegistryLoginEvents"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}