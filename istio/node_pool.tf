data "azurerm_subnet" "userone" {
  name                 = "User"
  virtual_network_name = module.network_one.vnet_name
  resource_group_name  = azurerm_resource_group.resource_group_one.name
  depends_on           = [module.network_one]
}

data "azurerm_subnet" "usertwo" {
  name                 = "User"
  virtual_network_name = module.network_two.vnet_name
  resource_group_name  = azurerm_resource_group.resource_group_two.name
  depends_on           = [module.network_two]
}

locals {
  user_one = {
    user = {
      name                  = var.user_agents_pool_name == null ? random_string.random.result : var.user_agents_pool_name
      kubernetes_cluster_id = module.aks_one.aks_id
      vnet_subnet_id        = data.azurerm_subnet.userone.id
      vm_size               = var.agents_size
      zones                 = var.agents_availability_zones
      enable_auto_scaling   = var.enable_auto_scaling
      max_pods              = var.agents_max_pods
      node_count            = var.agents_count
      min_count             = var.agents_min_count
      max_count             = var.agents_max_count
      os_disk_size_gb       = var.os_disk_size_gb
      os_disk_type          = var.os_disk_type
      node_labels           = var.user_agents_labels
      node_taints           = var.user_agents_taints
      tags                  = var.agents_tags
    }
  }
  user_two = {
    user = {
      name                  = var.user_agents_pool_name == null ? random_string.random.result : var.user_agents_pool_name
      kubernetes_cluster_id = module.aks_two.aks_id
      vnet_subnet_id        = data.azurerm_subnet.usertwo.id
      vm_size               = var.agents_size
      zones                 = var.agents_availability_zones
      enable_auto_scaling   = var.enable_auto_scaling
      max_pods              = var.agents_max_pods
      node_count            = var.agents_count
      min_count             = var.agents_min_count
      max_count             = var.agents_max_count
      os_disk_size_gb       = var.os_disk_size_gb
      os_disk_type          = var.os_disk_type
      node_labels           = var.user_agents_labels
      node_taints           = var.user_agents_taints
      tags                  = var.agents_tags
    }
  }
}
