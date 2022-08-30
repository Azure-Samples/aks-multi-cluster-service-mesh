
resource "azurerm_container_registry" "this" {
  name                = random_string.random.result
  resource_group_name = azurerm_resource_group.westeurope.name
  location            = azurerm_resource_group.westeurope.location
  sku                 = "Basic"
}

resource "azurerm_role_assignment" "this" {
  principal_id                     = module.aks-westeurope.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.this.id
  skip_service_principal_aad_check = true
  depends_on                       = [module.aks-westeurope]
}