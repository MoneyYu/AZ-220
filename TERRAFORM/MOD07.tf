## MOD-07-CONTAINER-REGISTRY
resource "azurerm_container_registry" "lab07" {
  name                     = local.lab02_name_with_postfix
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  sku                      = "Standard"
  admin_enabled            = true
}