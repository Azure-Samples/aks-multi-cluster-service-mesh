#name_prefix                           = "horus"
admin_username                      = "azadmin"
public_ssh_key                      = ""
agents_size                         = "Standard_D8a_v4"
rbac_aad_admin_group_object_ids     = []
identity_type                       = "UserAssigned"
kubernetes_version                  = "1.27.3"
orchestrator_version                = "1.27.3"
location_one                        = "westeurope"
location_two                        = "northeurope"
network_plugin                      = "azure"
network_policy                      = "azure"
sku_tier                            = "Standard"
role_based_access_control_enabled   = true
rbac_aad_azure_rbac_enabled         = true
rbac_aad_managed                    = true
private_cluster_enabled             = false
http_application_routing_enabled    = false
azure_policy_enabled                = true
enable_auto_scaling                 = true
enable_host_encryption              = false
log_analytics_workspace_enabled     = true
agents_min_count                    = 1
agents_max_count                    = 5
agents_count                        = 1
agents_max_pods                     = 100
os_disk_size_gb                     = 50
os_disk_type                        = "Ephemeral"
only_critical_addons_enabled        = true
agents_pool_name                    = "system"
user_agents_pool_name               = "user"
agents_availability_zones           = ["1", "2", "3"]
net_profile_outbound_type           = "loadBalancer"
agents_type                         = "VirtualMachineScaleSets"
ingress_application_gateway_enabled = true
key_vault_secrets_provider_enabled  = true
secret_rotation_enabled             = true
secret_rotation_interval            = "3m"
net_profile_dns_service_ip          = "172.16.0.10"
net_profile_docker_bridge_cidr      = "172.17.0.1/16"
net_profile_service_cidr            = "172.16.0.0/16"
agents_labels = {
  "nodepool" : "defaultnodepool"
}
user_agents_labels = {
  "nodepool" : "usernodepool"
}
agents_tags = {
  "resource" : "nodepool"
}
tags = {
  iac         = "Terraform"
  servicemesh = "Istio"
}
acr_sku                               = "Premium"
log_analytics_workspace_sku           = "PerGB2018"
log_analytics_worspace_retention_days = 30
vnet_one_address_space                = ["10.52.0.0/16"]
vnet_two_address_space                = ["10.53.0.0/16"]
vnet_one_subnet_prefixes              = ["10.52.0.0/24", "10.52.1.0/24", "10.52.2.0/24", "10.52.3.0/24", "10.52.4.0/24"]
vnet_two_subnet_prefixes              = ["10.53.0.0/24", "10.53.1.0/24", "10.53.2.0/24", "10.53.3.0/24"]
vnet_one_subnet_names                 = ["System", "User", "AppGateway", "AzureBastionSubnet", "PrivateEndpoints"]
vnet_two_subnet_names                 = ["System", "User", "AppGateway", "AzureBastionSubnet"]
key_vault_sku                         = "premium"
bastion_host_enabled                  = true