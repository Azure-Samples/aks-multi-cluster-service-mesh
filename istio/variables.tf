variable "name_prefix" {
  description = "(Optional) A prefix for the name of all the resource groups and resources."
  type        = string
  default     = null
  nullable    = true
}

variable "location_one" {
  description = "The location of the first cluster and related resources."
  type        = string
  default     = "westeurope"
}

variable "location_two" {
  description = "The location of the second cluster and related resources."
  type        = string
  default     = "eastus"
}

variable "client_id" {
  description = "(Optional) The Client ID (appId) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "client_secret" {
  description = "(Optional) The Client Secret (password) for the Service Principal used for the AKS deployment"
  type        = string
  default     = ""
}

variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
  type        = string
}

variable "only_critical_addons_enabled" {
  type        = bool
  description = "(Optional) Enabling this option will taint default node pool with `CriticalAddonsOnly=true:NoSchedule` taint. Changing this forces a new resource to be created."
  default     = null
}

variable "agents_size" {
  default     = "Standard_D8a_v4"
  description = "The default virtual machine size for the Kubernetes agents"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "Any tags that should be present on the Virtual Network resources"
  default     = {}
}

variable "enable_log_analytics_workspace" {
  type        = bool
  description = "Enable the creation of azurerm_log_analytics_workspace and azurerm_log_analytics_solution or not"
  default     = true
}

variable "vnet_subnet_id" {
  description = "(Optional) The ID of a Subnet where the Kubernetes Node Pool should exist. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "os_disk_size_gb" {
  description = "Disk size of nodes in GBs."
  type        = number
  default     = 50
}

variable "os_disk_type" {
  type        = string
  description = "The type of disk which should be used for the Operating System. Possible values are `Ephemeral` and `Managed`. Defaults to `Ephemeral`. Changing this forces a new resource to be created."
  default     = "Ephemeral"
  nullable    = false

  validation {
    condition     = contains(["Ephemeral", "Managed"], var.os_disk_type)
    error_message = "The OS disk type is incorrect."
  }
}

variable "public_ssh_key" {
  type        = string
  description = "(Optional) A custom ssh key to control access to the AKS cluster. Changing this forces a new resource to be created."
  default     = null
  nullable    = true
}

variable "enable_kube_dashboard" {
  description = "Enable Kubernetes Dashboard."
  type        = bool
  default     = false
}

variable "enable_azure_policy" {
  description = "Enable Azure Policy Addon."
  type        = bool
  default     = false
}

variable "enable_role_based_access_control" {
  description = "Enable Role Based Access Control."
  type        = bool
  default     = false
}

variable "rbac_aad_admin_group_object_ids" {
  description = "Object ID of groups with admin access."
  type        = list(string)
  default     = null
}

variable "rbac_aad_client_app_id" {
  description = "The Client ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_id" {
  description = "The Server ID of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "rbac_aad_server_app_secret" {
  description = "The Server Secret of an Azure Active Directory Application."
  type        = string
  default     = null
}

variable "kubernetes_version" {
  description = "Specify which Kubernetes release to use. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}

variable "orchestrator_version" {
  description = "Specify which Kubernetes release to use for the orchestration layer. The default used is the latest Kubernetes version available in the region"
  type        = string
  default     = null
}

variable "agents_pool_name" {
  description = "The default node pool name."
  type        = string
  default     = "system"
}

variable "user_agents_pool_name" {
  description = "(Optiobal) The user node pool name."
  type        = string
  default     = "user"
}

variable "user_agents_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool."
  type        = map(string)
  default     = {}
}

variable "user_agents_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

variable "enable_node_public_ip" {
  description = "(Optional) Should nodes in this Node Pool have a Public IP Address? Defaults to false."
  type        = bool
  default     = false
}

variable "enable_ingress_application_gateway" {
  description = "Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster?"
  type        = bool
  default     = null
}

variable "ingress_application_gateway_id" {
  description = "The ID of the Application Gateway to integrate with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "ingress_application_gateway_subnet_cidr" {
  description = "The subnet CIDR to be used to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}

variable "ingress_application_gateway_subnet_id" {
  description = "The ID of the subnet on which to create an Application Gateway, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
}
variable "identity_type" {
  description = "(Optional) The type of identity used for the managed cluster. Conflict with `client_id` and `client_secret`. Possible values are `SystemAssigned` and `UserAssigned`. If `UserAssigned` is set, a `user_assigned_identity_id` must be set as well."
  type        = string
  default     = "SystemAssigned"
}

variable "user_assigned_identity_id" {
  description = "(Optional) The ID of a user assigned identity."
  type        = string
  default     = null
}

variable "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster."
  type        = string
  default     = null
}

variable "network_plugin" {
  description = "(Required) Network plugin to use for networking. Currently supported values are azure, kubenet and none. Changing this forces a new resource to be created."
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "(Optional) Sets up network policy to be used with Azure CNI. Network policy allows us to control the traffic flow between pods. Currently supported values are calico and azure. Changing this forces a new resource to be created."
  type        = string
  default     = "azure"
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free"
  type        = string
  default     = "Free"
}

variable "role_based_access_control_enabled" {
  description = "(Optional) - Whether Role Based Access Control for the Kubernetes Cluster should be enabled. Defaults to true. Changing this forces a new resource to be created."
  type        = bool
  default     = true
}

variable "rbac_aad_managed" {
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
  type        = bool
  default     = true
}

variable "private_cluster_enabled" {
  description = "(Optional) Should this Kubernetes Cluster have its API server only exposed on internal IP addresses? This provides a Private IP Address for the Kubernetes API on the Virtual Network where the Kubernetes Cluster is located. Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled?"
  type        = bool
  default     = true
}

variable "enable_auto_scaling" {
  description = "(Optional) Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false"
  type        = bool
  default     = false
}

variable "enable_host_encryption" {
  description = "(Optional) Should the nodes in the Default Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_enabled" {
  description = "(Optional) Should an Azure Log Analytics workspace be created to monitor the cluster using Container Insights? Defaults to false."
  type        = bool
  default     = false
}

variable "agents_min_count" {
  description = "(Required) The minimum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
  type        = number
  default     = 1
}

variable "agents_max_count" {
  description = "(Required) The maximum number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000."
  type        = number
  default     = 1
}

variable "agents_count" {
  description = "(Optional) The initial number of nodes which should exist in this Node Pool. If specified this must be between 1 and 1000 and between min_count and max_count"
  type        = number
  default     = 1
}

variable "agents_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 30
}

variable "agents_availability_zones" {
  description = "(Optional) A list of Availability Zones across which the Node Pool should be spread. Changing this forces a new resource to be created"
  type        = list(string)
  default     = null
}

variable "agents_type" {
  description = "(Optional) The type of Node Pool which should be created. Possible values are AvailabilitySet and VirtualMachineScaleSets. Defaults to VirtualMachineScaleSets."
  type        = string
  default     = "VirtualMachineScaleSets"
}

variable "ingress_application_gateway_enabled" {
  description = "(Optional) Whether to deploy the Application Gateway ingress controller to this Kubernetes Cluster."
  type        = bool
  default     = false
  nullable    = false
}

variable "ingress_application_gateway_name" {
  description = "(Optional) The name of the Application Gateway to be used or created in the Nodepool Resource Group, which in turn will be integrated with the ingress controller of this Kubernetes Cluster."
  type        = string
  default     = null
  nullable    = true
}

variable "net_profile_dns_service_ip" {
  description = "(Optional) IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns). Changing this forces a new resource to be created."
  type        = string
  default     = "172.16.0.10"
}

variable "net_profile_docker_bridge_cidr" {
  description = "(Optional) IP address (in CIDR notation) used as the Docker bridge IP address on nodes. Changing this forces a new resource to be created."
  type        = string
  default     = "172.17.0.1/16"
}

variable "net_profile_outbound_type" {
  description = "(Optional) The outbound (egress) routing method which should be used for this Kubernetes Cluster. Possible values are loadBalancer and userDefinedRouting. Defaults to loadBalancer."
  type        = string
  default     = "loadBalancer"
}

variable "net_profile_pod_cidr" {
  description = " (Optional) The CIDR to use for pod IP addresses. This field can only be set when network_plugin is set to kubenet. Changing this forces a new resource to be created."
  type        = string
  default     = null
}

variable "net_profile_service_cidr" {
  description = "(Optional) The Network Range used by the Kubernetes service. Changing this forces a new resource to be created."
  type        = string
  default     = "172.16.0.0/16"
}

variable "key_vault_secrets_provider_enabled" {
  description = "(Optional) Whether to use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster. For more details: https://docs.microsoft.com/en-us/azure/aks/csi-secrets-store-driver"
  type        = bool
  default     = false
  nullable    = false
}

variable "secret_rotation_enabled" {
  description = "Is secret rotation enabled? This variable is only used when `key_vault_secrets_provider_enabled` is `true` and defaults to `false`."
  type        = bool
  default     = false
  nullable    = false
}

variable "secret_rotation_interval" {
  description = "The interval to poll for secret rotation. This attribute is only set when `secret_rotation` is `true` and defaults to `2m`."
  type        = string
  default     = "2m"
  nullable    = false
}

variable "agents_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in the Default Node Pool. Changing this forces a new resource to be created."
  type        = map(string)
  default     = {}
}

variable "agents_tags" {
  description = "(Optional) A mapping of tags to assign to the Node Pool."
  type        = map(string)
  default     = {}
}

variable "acr_sku" {
  description = "(Required) Specifies the SKU of the Azure Container Registry."
  type        = string
  default     = "Basic"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "log_analytics_workspace_sku" {
  description = "(Optional) Specifies the sku of the log analytics workspace."
  type        = string
  default     = "PerGB2018"

  validation {
    condition     = contains(["Free", "Standalone", "PerNode", "PerGB2018"], var.log_analytics_workspace_sku)
    error_message = "The log analytics sku is incorrect."
  }
}

variable "log_analytics_worspace_retention_days" {
  description = " (Optional) The workspace data retention in days. Possible values are either 7 (Free Tier only) or range between 30 and 730."
  type        = number
  default     = 30
}

variable "vnet_one_address_space" {
  description = "(Required) Specifies the address prefix of the first Azure virtual network."
  type        = list(string)
  default     = ["10.52.0.0/16"]
}

variable "vnet_two_address_space" {
  description = "(Required) Specifies the address prefix of the second Azure virtual network."
  type        = list(string)
  default     = ["10.53.0.0/16"]
}

variable "vnet_one_subnet_prefixes" {
  description = "(Required) The address prefixes to use for the subnets of the first Azure virtual network."
  type        = list(string)
  default     = ["10.52.0.0/24", "10.52.1.0/24", "10.52.2.0/24", "10.52.3.0/24", "10.52.4.0/24"]
}

variable "vnet_two_subnet_prefixes" {
  description = "(Required) The address prefixes to use for the subnets of the second Azure virtual network."
  type        = list(string)
  default     = ["10.53.0.0/24", "10.53.1.0/24", "10.53.2.0/24", "10.53.3.0/24", "10.53.4.0/24"]
}

variable "vnet_one_subnet_names" {
  description = "(Required) The names to use for the subnets of the first Azure virtual network."
  type        = list(string)
  default     = ["System", "User", "AppGateway", "AzureBastionSubnet", "PrivateEndpoints"]
}

variable "vnet_two_subnet_names" {
  description = "(Required) The names to use for the subnets of the second Azure virtual network."
  type        = list(string)
  default     = ["System", "User", "AppGateway", "AzureBastionSubnet", "PrivateEndpoints"]
}

variable "key_vault_sku" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku)
    error_message = "The sku name of the key vault is invalid."
  }
}

variable "bastion_host_enabled" {
  description = "(Optional) Specifies whether creating Azure Bastion Host for virtual networks."
  type        = bool
  default     = true
}
