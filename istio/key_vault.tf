data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                       = var.name_prefix == null ? "${random_string.random.result}-key-vault" : "${var.name_prefix}-key-vault"
  location                   = azurerm_resource_group.resource_group_shared.location
  resource_group_name        = azurerm_resource_group.resource_group_shared.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.key_vault_sku
  soft_delete_retention_days = 7
  tags                       = var.tags

  access_policy {
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge"

    ]
    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "Purge",
      "Encrypt",
      "Decrypt",
      "Sign",
      "Verify"
    ]
    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "ManageContacts",
      "ManageIssuers",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = module.aks_one.key_vault_secrets_provider.secret_identity[0].object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    certificate_permissions = [
      "Get",
    ]
  }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = module.aks_two.key_vault_secrets_provider.secret_identity[0].object_id

    key_permissions = [
      "Get",
    ]

    secret_permissions = [
      "Get",
    ]

    certificate_permissions = [
      "Get",
    ]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "key_vault__diagnostics_settings" {
  name                       = "diagnostics-settings"
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id

  log {
    category = "AuditEvent"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "AzurePolicyEvaluationDetails"
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