module "network_one" {
  source              = "Azure/network/azurerm"
  vnet_name           = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-vnet" : "${var.name_prefix}-${var.location_one}-vnet"
  resource_group_name = azurerm_resource_group.resource_group_one.name
  address_spaces      = var.vnet_one_address_space
  subnet_prefixes     = var.vnet_one_subnet_prefixes
  subnet_names        = var.vnet_one_subnet_names
  depends_on          = [azurerm_resource_group.resource_group_one]
  subnet_enforce_private_link_endpoint_network_policies = {
    "subnet1" : true
  }
}

module "network_two" {
  source              = "Azure/network/azurerm"
  vnet_name           = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}-vnet" : "${var.name_prefix}-${var.location_two}-vnet"
  resource_group_name = azurerm_resource_group.resource_group_two.name
  address_spaces      = var.vnet_two_address_space
  subnet_prefixes     = var.vnet_two_subnet_prefixes
  subnet_names        = var.vnet_two_subnet_names
  depends_on          = [azurerm_resource_group.resource_group_two]
  subnet_enforce_private_link_endpoint_network_policies = {
    "subnet1" : true
  }
}

resource "azurerm_virtual_network_peering" "one-to-two" {
  name                      = "${module.network_one.vnet_name}-to-${module.network_two.vnet_name}"
  resource_group_name       = azurerm_resource_group.resource_group_one.name
  virtual_network_name      = module.network_one.vnet_name
  remote_virtual_network_id = module.network_two.vnet_id
}

resource "azurerm_virtual_network_peering" "two-to-one" {
  name                      = "${module.network_two.vnet_name}-to-${module.network_one.vnet_name}"
  resource_group_name       = azurerm_resource_group.resource_group_two.name
  virtual_network_name      = module.network_two.vnet_name
  remote_virtual_network_id = module.network_one.vnet_id
}

# Grant AKS cluster access to use AKS subnet
resource "azurerm_role_assignment" "aks_one_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks_identity_one.principal_id
  role_definition_name = "Network Contributor"
  scope                = module.network_one.vnet_id
  depends_on           = [module.aks_one]
}

resource "azurerm_role_assignment" "aks_two_network_contributor" {
  principal_id         = azurerm_user_assigned_identity.aks_identity_two.principal_id
  role_definition_name = "Network Contributor"
  scope                = module.network_two.vnet_id
  depends_on           = [module.aks_two]
}

resource "azurerm_monitor_diagnostic_setting" "vnet_one_diagnostics_settings" {
  name                       = "diagnostics-settings"
  target_resource_id         = module.network_one.vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id

  log {
    category = "VMProtectionAlerts"
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

resource "azurerm_monitor_diagnostic_setting" "vnet_two_diagnostics_settings" {
  name                       = "diagnostics-settings"
  target_resource_id         = module.network_two.vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_two.id

  log {
    category = "VMProtectionAlerts"
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
