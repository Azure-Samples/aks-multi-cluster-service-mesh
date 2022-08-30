

output "secret-provider-class-westeurope" {
  value = templatefile("secret-provider-class.tftpl", { userAssignedIdentityID = module.aks-westeurope.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = random_string.random.result, tenant = data.azurerm_client_config.current.tenant_id, location = "westeurope" })
}
output "secret-provider-class-eastus" {
  value = templatefile("secret-provider-class.tftpl", { userAssignedIdentityID = module.aks-eastus.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = random_string.random.result, tenant = data.azurerm_client_config.current.tenant_id, location = "eastus" })
}

output "secret-provider-class-ingress" {
  value = templatefile("secret-provider-class-ingress.tftpl", { userAssignedIdentityID = module.aks-eastus.key_vault_secrets_provider.secret_identity[0].client_id, vaultname = random_string.random.result, tenant = data.azurerm_client_config.current.tenant_id })
}
