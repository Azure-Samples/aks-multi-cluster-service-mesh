output "random_prefix" {
  value       = random_string.random.result
  description = "Specifies the random value that is used as a prefix for the name of all the Azure resources when not explicitly defined in variables."
}

output "secret_provider_class_location_one" {
  value = templatefile("secret_provider_class.tftpl", { aksName = module.aks_one.aks_name, clientId = module.aks_one.key_vault_secrets_provider.secret_identity[0].client_id, vaultName = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id })
}

output "secret_provider_class_location_two" {
  value = templatefile("secret_provider_class.tftpl", { aksName = module.aks_two.aks_name, clientId = module.aks_two.key_vault_secrets_provider.secret_identity[0].client_id, vaultName = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id })
}

output "secret_provider_class_ingress_one" {
  value = templatefile("secret_provider_class_ingress.tftpl", { clientId = module.aks_one.key_vault_secrets_provider.secret_identity[0].client_id, vaultName = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id })
}

output "secret_provider_class_ingress_two" {
  value = templatefile("secret_provider_class_ingress.tftpl", { clientId = module.aks_two.key_vault_secrets_provider.secret_identity[0].client_id, vaultName = azurerm_key_vault.key_vault.name, tenant = data.azurerm_client_config.current.tenant_id })
}
