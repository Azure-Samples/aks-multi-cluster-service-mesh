
module "network-eastus" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.eastus.name
  address_space       = "10.52.0.0/16"
  subnet_prefixes     = ["10.52.0.0/24", "10.52.1.0/24", "10.52.2.0/24", "10.52.200.0/24"]
  subnet_names        = ["aks-system", "north001", "north002", "appgw"]
  depends_on          = [azurerm_resource_group.eastus]
  subnet_enforce_private_link_endpoint_network_policies = {
    "subnet1" : true
  }
}

module "network-westeurope" {
  source              = "Azure/network/azurerm"
  resource_group_name = azurerm_resource_group.westeurope.name
  address_space       = "10.53.0.0/16"
  subnet_prefixes     = ["10.53.0.0/24", "10.53.1.0/24", "10.53.2.0/24", "10.53.200.0/24"]
  subnet_names        = ["aks-system", "west001", "west002", "appgw"]
  depends_on          = [azurerm_resource_group.westeurope]
  subnet_enforce_private_link_endpoint_network_policies = {
    "subnet1" : true
  }
}

resource "azurerm_virtual_network_peering" "north2west" {
  name                      = "north2west"
  resource_group_name       = azurerm_resource_group.eastus.name
  virtual_network_name      = module.network-eastus.vnet_name
  remote_virtual_network_id = module.network-westeurope.vnet_id
}

resource "azurerm_virtual_network_peering" "west2north" {
  name                      = "west2north"
  resource_group_name       = azurerm_resource_group.westeurope.name
  virtual_network_name      = module.network-westeurope.vnet_name
  remote_virtual_network_id = module.network-eastus.vnet_id
}

# Grant AKS cluster access to use AKS subnet
resource "azurerm_role_assignment" "aks-eastus" {
  principal_id         = module.aks-eastus.cluster_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = module.network-eastus.vnet_subnets[0]
  depends_on           = [module.aks-eastus]
}

resource "azurerm_role_assignment" "aks-westeurope" {
  principal_id         = module.aks-westeurope.cluster_identity.principal_id
  role_definition_name = "Network Contributor"
  scope                = module.network-westeurope.vnet_subnets[0]
  depends_on           = [module.aks-westeurope]
}