resource "azurerm_private_endpoint" "container_registry_private_endpoint" {
  name                = var.name_prefix == null ? "${random_string.random.result}-acr-private-endpoint" : "${var.name_prefix}-acr-private-endpoint"
  location            = azurerm_resource_group.resource_group_shared.location
  resource_group_name = azurerm_resource_group.resource_group_shared.name
  subnet_id           = module.network_one.vnet_subnets[4]
  tags                = var.tags

  private_service_connection {
    name                           = "container-registry-connection"
    private_connection_resource_id = azurerm_container_registry.container_registry.id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "container-registry-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.container_registry_private_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_endpoint" "key_vault_private_endpoint" {
  name                = var.name_prefix == null ? "${random_string.random.result}-key-vault-private-endpoint" : "${var.name_prefix}-key-vault-private-endpoint"
  location            = azurerm_resource_group.resource_group_shared.location
  resource_group_name = azurerm_resource_group.resource_group_shared.name
  subnet_id           = module.network_one.vnet_subnets[4]
  tags                = var.tags

  private_service_connection {
    name                           = "key-vault-connection"
    private_connection_resource_id = azurerm_key_vault.key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  private_dns_zone_group {
    name                 = "key-vault-private-dns-zone-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.key_vault_private_dns_zone.id]
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}