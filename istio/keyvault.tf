data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "keyvault" {
   name     = "keyvault-rg"
   location = "eastus"
 }

resource "azurerm_key_vault" "this" {
  name                       = "kv-${random_string.random.result}"
  location                   = azurerm_resource_group.keyvault.location
  resource_group_name        = azurerm_resource_group.keyvault.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "premium"
  soft_delete_retention_days = 7

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
    object_id = module.aks-westeurope.key_vault_secrets_provider.secret_identity[0].object_id

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
    object_id = module.aks-eastus.key_vault_secrets_provider.secret_identity[0].object_id

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
}

