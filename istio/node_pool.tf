resource "azurerm_kubernetes_cluster_node_pool" "user_one" {
  name                  = var.user_agents_pool_name == null ? random_string.random.result : var.user_agents_pool_name
  kubernetes_cluster_id = module.aks_one.aks_id
  vnet_subnet_id        = module.network_one.vnet_subnets[1]
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
  depends_on            = [module.network_one]
}

resource "azurerm_kubernetes_cluster_node_pool" "user_two" {
  name                  = var.user_agents_pool_name == null ? random_string.random.result : var.user_agents_pool_name
  kubernetes_cluster_id = module.aks_two.aks_id
  vnet_subnet_id        = module.network_two.vnet_subnets[1]
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
  depends_on            = [module.network_two]
}
