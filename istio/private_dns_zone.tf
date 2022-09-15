resource "azurerm_private_dns_zone" "container_registry_private_dns_zone" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.resource_group_shared.name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_zone" "key_vault_private_dns_zone" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.resource_group_shared.name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry_private_dns_zone_link_to_vnet_one" {
  name                  = "link-to-${lower(module.network_one.vnet_name)}"
  resource_group_name   = azurerm_resource_group.resource_group_shared.name
  private_dns_zone_name = azurerm_private_dns_zone.container_registry_private_dns_zone.name
  virtual_network_id    = module.network_one.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_private_dns_zone_link_to_vnet_one" {
  name                  = "link-to-${lower(module.network_one.vnet_name)}"
  resource_group_name   = azurerm_resource_group.resource_group_shared.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault_private_dns_zone.name
  virtual_network_id    = module.network_one.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_registry_private_dns_zone_link_to_vnet_two" {
  name                  = "link-to-${lower(module.network_two.vnet_name)}"
  resource_group_name   = azurerm_resource_group.resource_group_shared.name
  private_dns_zone_name = azurerm_private_dns_zone.container_registry_private_dns_zone.name
  virtual_network_id    = module.network_two.vnet_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault_private_dns_zone_link_to_vnet_two" {
  name                  = "link-to-${lower(module.network_two.vnet_name)}"
  resource_group_name   = azurerm_resource_group.resource_group_shared.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault_private_dns_zone.name
  virtual_network_id    = module.network_two.vnet_id
}