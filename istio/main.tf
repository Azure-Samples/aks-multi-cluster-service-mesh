resource "random_string" "random" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

module "aks_one" {
  source                                = "git::https://github.com/Azure/terraform-azurerm-aks.git"
  resource_group_name                   = azurerm_resource_group.resource_group_one.name
  kubernetes_version                    = var.kubernetes_version
  orchestrator_version                  = var.orchestrator_version
  cluster_name                          = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}" : "${var.name_prefix}-${var.location_one}"
  prefix                                = var.name_prefix == null ? "${random_string.random.result}-${var.location_one}" : "${var.name_prefix}-${var.location_one}"
  location                              = var.location_one
  identity_type                         = var.identity_type
  identity_ids                          = [azurerm_user_assigned_identity.aks_identity_one.id]
  network_plugin                        = var.network_plugin
  network_policy                        = var.network_policy
  vnet_subnet_id                        = module.network_one.vnet_subnets[0]
  os_disk_size_gb                       = var.os_disk_size_gb
  os_disk_type                          = var.os_disk_type
  admin_username                        = var.admin_username
  public_ssh_key                        = var.public_ssh_key
  only_critical_addons_enabled          = var.only_critical_addons_enabled
  sku_tier                              = var.sku_tier
  role_based_access_control_enabled     = var.role_based_access_control_enabled
  rbac_aad_admin_group_object_ids       = var.rbac_aad_admin_group_object_ids
  rbac_aad_managed                      = var.rbac_aad_managed
  private_cluster_enabled               = var.private_cluster_enabled
  http_application_routing_enabled      = var.http_application_routing_enabled
  azure_policy_enabled                  = var.azure_policy_enabled
  enable_auto_scaling                   = var.enable_auto_scaling
  enable_host_encryption                = var.enable_host_encryption
  log_analytics_workspace_enabled       = var.log_analytics_workspace_enabled
  log_analytics_workspace               = {
    id   = azurerm_log_analytics_workspace.log_analytics_workspace_one.id
    name = azurerm_log_analytics_workspace.log_analytics_workspace_one.name
  }
  log_analytics_solution_id             = null
  agents_min_count                      = var.agents_min_count
  agents_max_count                      = var.agents_max_count
  agents_count                          = var.agents_count # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                       = var.agents_max_pods
  agents_pool_name                      = var.agents_pool_name
  agents_availability_zones             = var.agents_availability_zones
  net_profile_outbound_type             = var.net_profile_outbound_type
  agents_type                           = var.agents_type
  agents_size                           = var.agents_size
  ingress_application_gateway_enabled   = var.ingress_application_gateway_enabled
  ingress_application_gateway_name      = var.ingress_application_gateway_name == null ? "aks-appgw-${var.location_one}" : var.ingress_application_gateway_name  
  ingress_application_gateway_subnet_id = module.network_one.vnet_subnets[2]
  net_profile_dns_service_ip            = var.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr        = var.net_profile_docker_bridge_cidr
  net_profile_service_cidr              = var.net_profile_service_cidr
  key_vault_secrets_provider_enabled    = var.key_vault_secrets_provider_enabled
  secret_rotation_enabled               = var.secret_rotation_enabled
  secret_rotation_interval              = var.secret_rotation_interval
  agents_labels                         = var.agents_labels
  agents_tags                           = var.agents_tags
  tags                                  = var.tags

  depends_on = [module.network_one]
}

module "aks_two" {
  source                                = "git::https://github.com/Azure/terraform-azurerm-aks.git"
  resource_group_name                   = azurerm_resource_group.resource_group_two.name
  kubernetes_version                    = var.kubernetes_version
  orchestrator_version                  = var.orchestrator_version
  cluster_name                          = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}" : "${var.name_prefix}-${var.location_two}"
  prefix                                = var.name_prefix == null ? "${random_string.random.result}-${var.location_two}" : "${var.name_prefix}-${var.location_two}"
  location                              = var.location_two
  identity_type                         = var.identity_type
  identity_ids                          = [azurerm_user_assigned_identity.aks_identity_two.id]
  network_plugin                        = var.network_plugin
  network_policy                        = var.network_policy
  vnet_subnet_id                        = module.network_two.vnet_subnets[0]
  os_disk_size_gb                       = var.os_disk_size_gb
  os_disk_type                          = var.os_disk_type
  admin_username                        = var.admin_username
  public_ssh_key                        = var.public_ssh_key
  only_critical_addons_enabled          = var.only_critical_addons_enabled
  sku_tier                              = var.sku_tier
  role_based_access_control_enabled     = var.role_based_access_control_enabled
  rbac_aad_admin_group_object_ids       = var.rbac_aad_admin_group_object_ids
  rbac_aad_managed                      = var.rbac_aad_managed
  private_cluster_enabled               = var.private_cluster_enabled
  http_application_routing_enabled      = var.http_application_routing_enabled
  azure_policy_enabled                  = var.azure_policy_enabled
  enable_auto_scaling                   = var.enable_auto_scaling
  enable_host_encryption                = var.enable_host_encryption
  log_analytics_workspace_enabled       = var.log_analytics_workspace_enabled
  log_analytics_workspace               = {
    id   = azurerm_log_analytics_workspace.log_analytics_workspace_two.id
    name = azurerm_log_analytics_workspace.log_analytics_workspace_two.name
  }
  log_analytics_solution_id             = null
  agents_min_count                      = var.agents_min_count
  agents_max_count                      = var.agents_max_count
  agents_count                          = var.agents_count # Please set `agents_count` `null` while `enable_auto_scaling` is `true` to avoid possible `agents_count` changes.
  agents_max_pods                       = var.agents_max_pods
  agents_pool_name                      = var.agents_pool_name
  agents_availability_zones             = var.agents_availability_zones
  net_profile_outbound_type             = var.net_profile_outbound_type
  agents_type                           = var.agents_type
  agents_size                           = var.agents_size
  ingress_application_gateway_enabled   = var.ingress_application_gateway_enabled
  ingress_application_gateway_name      = var.ingress_application_gateway_name == null ? "aks-appgw-${var.location_two}" : var.ingress_application_gateway_name  
  ingress_application_gateway_subnet_id = module.network_two.vnet_subnets[2]
  net_profile_dns_service_ip            = var.net_profile_dns_service_ip
  net_profile_docker_bridge_cidr        = var.net_profile_docker_bridge_cidr
  net_profile_service_cidr              = var.net_profile_service_cidr
  key_vault_secrets_provider_enabled    = var.key_vault_secrets_provider_enabled
  secret_rotation_enabled               = var.secret_rotation_enabled
  secret_rotation_interval              = var.secret_rotation_interval
  agents_labels                         = var.agents_labels
  agents_tags                           = var.agents_tags
  tags                                  = var.tags

  depends_on = [module.network_two]
}

resource "azurerm_monitor_diagnostic_setting" "aks_one_diagnostics_settings" {
  name                       = "diagnostics-settings"
  target_resource_id         = module.aks_one.aks_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_one.id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = true  
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "cloud-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "guard"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "csi-azuredisk-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "csi-azurefile-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "csi-snapshot-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks_two_diagnostics_settings" {
  name                       = "diagnostics-settings"
  target_resource_id         = module.aks_two.aks_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace_two.id

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = true  
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-audit-admin"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "cloud-controller-manager"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "guard"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "csi-azuredisk-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "csi-azurefile-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  log {
    category = "csi-snapshot-controller"
    enabled  = true

    retention_policy {
      enabled = true
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
    }
  }
}