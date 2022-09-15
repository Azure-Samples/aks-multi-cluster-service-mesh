resource "azurerm_user_assigned_identity" "aks_identity_one" {
  resource_group_name = azurerm_resource_group.resource_group_one.name
  location            = var.location_one
  tags                = var.tags

  name = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-identity" : "${var.name_prefix}-${var.location_one}-identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_user_assigned_identity" "aks_identity_two" {
  resource_group_name = azurerm_resource_group.resource_group_two.name
  location            = var.location_two
  tags                = var.tags

  name = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}-identity" : "${var.name_prefix}-${var.location_two}-identity"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}