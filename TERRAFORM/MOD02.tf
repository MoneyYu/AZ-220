## MOD-02-IOT-HUB
resource "azurerm_storage_account" "lab02" {
  name                     = lower("${local.lab02_name}stor${random_string.rid.result}")
  resource_group_name      = azurerm_resource_group.group.name
  location                 = azurerm_resource_group.group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "lab02" {
  name                  = "iotcontainer"
  storage_account_name  = azurerm_storage_account.lab02.name
  container_access_type = "private"
}

resource "azurerm_eventhub_namespace" "lab02" {
  name                = lower("${local.lab02_name}-eventspace-${random_string.rid.result}")
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location
  sku                 = "Standard"
}

resource "azurerm_eventhub" "lab02" {
  name                = lower("${local.lab02_name}-eventhub-${random_string.rid.result}")
  resource_group_name = azurerm_resource_group.group.name
  namespace_name      = azurerm_eventhub_namespace.lab02.name
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_authorization_rule" "lab02" {
  resource_group_name = azurerm_resource_group.group.name
  namespace_name      = azurerm_eventhub_namespace.lab02.name
  eventhub_name       = azurerm_eventhub.lab02.name
  name                = local.lab02_name_with_postfix
  send                = true
}

resource "azurerm_iothub" "lab02" {
  name                = lower("${local.lab02_name}-iothub-${random_string.rid.result}")
  resource_group_name = azurerm_resource_group.group.name
  location            = azurerm_resource_group.group.location

  sku {
    name     = "S1"
    capacity = "1"
  }

  endpoint {
    type                       = "AzureIotHub.StorageContainer"
    connection_string          = azurerm_storage_account.lab02.primary_blob_connection_string
    name                       = "export"
    batch_frequency_in_seconds = 60
    max_chunk_size_in_bytes    = 10485760
    container_name             = azurerm_storage_container.lab02.name
    encoding                   = "Avro"
    file_name_format           = "{iothub}/{partition}_{YYYY}_{MM}_{DD}_{HH}_{mm}"
  }

  endpoint {
    type              = "AzureIotHub.EventHub"
    connection_string = azurerm_eventhub_authorization_rule.lab02.primary_connection_string
    name              = "export2"
  }

  route {
    name           = "export"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export"]
    enabled        = true
  }

  route {
    name           = "export2"
    source         = "DeviceMessages"
    condition      = "true"
    endpoint_names = ["export2"]
    enabled        = true
  }

  tags = {
    environment = local.group_name
  }
}