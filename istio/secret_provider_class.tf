output "secret_provider_class_location_one" {
  value = templatefile("secret_provider_class.tftpl", { userAssignedIdentityID = module.aks_one.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id, location = module.aks_one.location })
}

output "secret_provider_class_location_two" {
  value = templatefile("secret_provider_class.tftpl", { userAssignedIdentityID = module.aks_two.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id, location = module.aks_two.location })
}

output "secret_provider_class_ingress" {
  value = templatefile("secret_provider_class_ingress.tftpl", { userAssignedIdentityID = module.aks_two.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id })
}
