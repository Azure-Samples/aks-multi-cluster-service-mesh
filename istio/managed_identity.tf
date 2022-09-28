resource "azurerm_user_assigned_identity" "aks_identity_one" {
  resource_group_name = azurerm_resource_group.resource_group_one.name
  location            = var.location_one
  tags                = var.tags

  name = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}-identity-one" : "${var.name_prefix}-${var.location_one}-identity-one"

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

  name = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}-identity-two" : "${var.name_prefix}-${var.location_two}-identity-two"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}