## MOD-03-DPS
resource "azurerm_iothub_dps" "lab03" {
  name                = lower("${local.lab03_name}-dps-${random_string.rid.result}")
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  allocation_policy   = "Hashed"

  sku {
    name     = "S1"
    capacity = "1"
  }

  linked_hub {
    connection_string = data.azurerm_iothub_shared_access_policy.iothubowner.primary_connection_string
    location          = azurerm_resource_group.group.location
  }
}

data "azurerm_iothub_shared_access_policy" "iothubowner" {
  name                = "iothubowner"
  resource_group_name = azurerm_resource_group.group.name
  iothub_name         = azurerm_iothub.lab02.name
}