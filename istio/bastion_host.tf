resource "azurerm_public_ip" "public_ip_one" {
  count = var.bastion_host_enabled ? 1 : 0

  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-bastion-host-public-ip" : "${var.name_prefix}-${var.location_one}-bastion-host-public-ip"
  location            = var.location_one
  resource_group_name = azurerm_resource_group.resource_group_one.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_bastion_host" "bastion_host_one" {
  count = var.bastion_host_enabled ? 1 : 0

  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-bastion-host" : "${var.name_prefix}-${var.location_one}-bastion-host"
  location            = var.location_one
  resource_group_name = azurerm_resource_group.resource_group_one.name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.network_one.vnet_subnets[3]
    public_ip_address_id = azurerm_public_ip.public_ip_one[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  depends_on = [
    azurerm_public_ip.public_ip_one[0]
  ]
}

resource "azurerm_monitor_diagnostic_setting" "bastion_host_one_diagnostics_settings" {
  count = var.bastion_host_enabled ? 1 : 0

  name                       = "diagnostics-settings"
  target_resource_id         = azurerm_bastion_host.bastion_host_one[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id

  log {
    category = "BastionAuditLogs"
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

resource "azurerm_monitor_diagnostic_setting" "public_ip_one_diagnostics_settings" {
  count = var.bastion_host_enabled ? 1 : 0

  name                       = "diagnostics-settings"
  target_resource_id         = azurerm_public_ip.public_ip_one[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "DDoSMitigationReports"
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

resource "azurerm_public_ip" "public_ip_two" {
  count = var.bastion_host_enabled ? 1 : 0

  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}-bastion-host-public-ip" : "${var.name_prefix}-${var.location_two}-bastion-host-public-ip"
  location            = var.location_two
  resource_group_name = azurerm_resource_group.resource_group_two.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_bastion_host" "bastion_host_two" {
  count = var.bastion_host_enabled ? 1 : 0

  name                = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}-bastion-host" : "${var.name_prefix}-${var.location_two}-bastion-host"
  location            = var.location_two
  resource_group_name = azurerm_resource_group.resource_group_two.name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = module.network_two.vnet_subnets[3]
    public_ip_address_id = azurerm_public_ip.public_ip_two[0].id
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }

  depends_on = [
    azurerm_public_ip.public_ip_two[0]
  ]
}

resource "azurerm_monitor_diagnostic_setting" "bastion_host_two_diagnostics_settings" {
  count = var.bastion_host_enabled ? 1 : 0

  name                       = "diagnostics-settings"
  target_resource_id         = azurerm_bastion_host.bastion_host_two[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_two.id

  log {
    category = "BastionAuditLogs"
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

resource "azurerm_monitor_diagnostic_setting" "public_ip_two_diagnostics_settings" {
  count = var.bastion_host_enabled ? 1 : 0

  name                       = "diagnostics-settings"
  target_resource_id         = azurerm_public_ip.public_ip_two[0].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_two.id

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "DDoSMitigationReports"
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