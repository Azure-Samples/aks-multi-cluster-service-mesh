resource "azurerm_kubernetes_cluster_node_pool" "west001" {
  name                  = "west001"
  kubernetes_cluster_id = module.aks-westeurope.aks_id
  vm_size               = var.agents_size
  node_count            = 1
  vnet_subnet_id        = module.network-westeurope.vnet_subnets[1]
  depends_on            = [module.network-westeurope]

}

resource "azurerm_kubernetes_cluster_node_pool" "west002" {
  name                  = "west002"
  kubernetes_cluster_id = module.aks-westeurope.aks_id
  vm_size               = var.agents_size
  node_count            = 1
  vnet_subnet_id        = module.network-westeurope.vnet_subnets[2]
  depends_on            = [module.network-westeurope]

}

resource "azurerm_kubernetes_cluster_node_pool" "east001" {
  name                  = "east001"
  kubernetes_cluster_id = module.aks-eastus.aks_id
  vm_size               = var.agents_size
  node_count            = 1
  vnet_subnet_id        = module.network-eastus.vnet_subnets[1]
  depends_on            = [module.network-eastus]

}

resource "azurerm_kubernetes_cluster_node_pool" "east002" {
  name                  = "east002"
  kubernetes_cluster_id = module.aks-eastus.aks_id
  vm_size               = var.agents_size
  node_count            = 1
  vnet_subnet_id        = module.network-eastus.vnet_subnets[2]
  depends_on            = [module.network-eastus]

}