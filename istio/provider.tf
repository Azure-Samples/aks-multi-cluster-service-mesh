terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.10.0"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "azurerm_resource_group" "westeurope" {
  name     = join("-", [var.resource_group_name, "westeurope"])
  location = "westeurope"
}

resource "azurerm_resource_group" "eastus" {
  name     = join("-", [var.resource_group_name, "eastus"])
  location = "eastus"
}
