resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
}


module "aks-westeurope" {
  source                            = "git::https://github.com/Azure/terraform-azurerm-aks.git"
  resource_group_name               = azurerm_resource_group.westeurope.name
  kubernetes_version                = "1.23.5"
  orchestrator_version              = "1.23.5"
  prefix                            = azurerm_resource_group.westeurope.location
  network_plugin                    = "azure"
  vnet_subnet_id                    = module.network-westeurope.vnet_subnets[0]
  os_disk_size_gb                   = 50
  sku_tier                          = "Paid" # defaults to Free
  role_based_access_control_enabled = true
  rbac_aad_admin_group_object_ids   = var.rbac_aad_admin_group_object_ids
  rbac_aad_managed                  = true
  private_cluster_enabled           = false
  http_application_routing_enabled  = false
  azure_policy_enabled              = true
  enable_auto_scaling               = true
  enable_host_encryption            = false
  log_analytics_workspace_enabled   = false
  agents_min_count                  = 1
  agents_max_count                  = 1
  agents_count                      = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                   = 100
  agents_pool_name                  = "exnodepool"
  agents_availability_zones         = ["1", "2"]
  agents_type                       = "VirtualMachineScaleSets"
  agents_size                       = var.agents_size

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  ingress_application_gateway_enabled   = true
  ingress_application_gateway_name      = "aks-agw-westeurope"
  ingress_application_gateway_subnet_id = module.network-westeurope.vnet_subnets[3]

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.0.0.10"
  net_profile_docker_bridge_cidr = "172.17.0.1/16"
  net_profile_service_cidr       = "10.0.0.0/16"

  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled            = true
  secret_rotation_interval           = "3m"

  depends_on = [module.network-westeurope]
}

module "aks-eastus" {
  source                            = "git::https://github.com/Azure/terraform-azurerm-aks.git"
  resource_group_name               = azurerm_resource_group.eastus.name
  kubernetes_version                = "1.23.5"
  orchestrator_version              = "1.23.5"
  prefix                            = azurerm_resource_group.eastus.location
  network_plugin                    = "azure"
  vnet_subnet_id                    = module.network-eastus.vnet_subnets[0]
  os_disk_size_gb                   = 50
  sku_tier                          = "Paid" # defaults to Free
  role_based_access_control_enabled = true
  rbac_aad_admin_group_object_ids   = var.rbac_aad_admin_group_object_ids
  rbac_aad_managed                  = true
  private_cluster_enabled           = false
  http_application_routing_enabled  = false
  azure_policy_enabled              = true
  enable_auto_scaling               = true
  enable_host_encryption            = false
  log_analytics_workspace_enabled   = false
  agents_min_count                  = 1
  agents_max_count                  = 1
  agents_count                      = null # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                   = 100
  agents_pool_name                  = "exnodepool"
  agents_availability_zones         = ["1", "2"]
  agents_type                       = "VirtualMachineScaleSets"
  agents_size                       = var.agents_size

  agents_labels = {
    "nodepool" : "defaultnodepool"
  }

  agents_tags = {
    "Agent" : "defaultnodepoolagent"
  }

  ingress_application_gateway_enabled   = true
  ingress_application_gateway_name      = "aks-agw-eastus"
  ingress_application_gateway_subnet_id = module.network-eastus.vnet_subnets[3]

  network_policy                 = "azure"
  net_profile_dns_service_ip     = "10.1.0.10"
  net_profile_docker_bridge_cidr = "172.17.0.1/16"
  net_profile_service_cidr       = "10.1.0.0/16"

  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled            = true
  secret_rotation_interval           = "3m"

  depends_on = [module.network-eastus]
}
