resource "azurerm_resource_group" "resource_group_one" {
  name     = join("-", [var.name_prefix == null ? random_string.random.result : var.name_prefix, var.location_one, "rg"])
  location = var.location_one
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_resource_group" "resource_group_two" {
  name     = join("-", [var.name_prefix == null ? random_string.random.result : var.name_prefix, var.location_two, "rg"])
  location = var.location_two
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_resource_group" "resource_group_shared" {
  name     = join("-", [var.name_prefix == null ? random_string.random.result : var.name_prefix, "shared", "rg"])
  location = var.location_one
  tags     = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}