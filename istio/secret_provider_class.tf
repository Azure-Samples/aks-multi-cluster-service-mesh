output "secret_provider_class_location_one" {
  value = templatefile("secret_provider_class.tftpl", { userAssignedIdentityID = module.aks_one.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = random_string.random.result, tenant = data.azurerm_client_config.current.tenant_id, location = "westeurope" })
}

output "secret_provider_class_location_two" {
  value = templatefile("secret_provider_class.tftpl", { userAssignedIdentityID = module.aks_two.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = random_string.random.result, tenant = data.azurerm_client_config.current.tenant_id, location = "eastus" })
}

output "secret_provider_class_ingress" {
  value = templatefile("secret_provider_class_ingress.tftpl", { userAssignedIdentityID = module.aks_two.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = random_string.random.result, tenant = data.azurerm_client_config.current.tenant_id })
}
