## MOD-07-CONTAINER-REGISTRY
resource "azurerm_container_registry" "lab07" {
  name                     = "${local.lab07_name}acr${random_string.rid.result}"
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  sku                      = "Standard"
  admin_enabled            = true
}