## MOD-06-EDGE-GATEWAY
resource "azurerm_virtual_network" "lab06" {
  name                = local.lab06_name_with_postfix
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
}

resource "azurerm_subnet" "lab06" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.group.name
  virtual_network_name = azurerm_virtual_network.lab06.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_public_ip" "lab06" {
  name                = local.lab06_name_with_postfix
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name
  allocation_method   = "Dynamic"
  domain_name_label   = local.lab06_name_with_postfix

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_network_interface" "lab06" {
  name                = local.lab06_name_with_postfix
  location            = azurerm_resource_group.group.location
  resource_group_name = azurerm_resource_group.group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lab06.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.lab06.id
  }

  tags = {
    environment = local.group_name
  }
}

resource "azurerm_linux_virtual_machine" "lab06" {
  name                            = local.lab06_name_with_postfix
  resource_group_name             = azurerm_resource_group.group.name
  location                        = azurerm_resource_group.group.location
  size                            = "Standard_D4s_v4"
  disable_password_authentication = false
  admin_username                  = local.user_name
  admin_password                  = local.user_passowrd
  network_interface_ids = [
    azurerm_network_interface.lab06.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "microsoft_iot_edge"
    offer     = "iot_edge_vm_ubuntu"
    sku       = "ubuntu_1604_edgeruntimeonly"
    version   = "latest"
  }

  plan {
    name      = "ubuntu_1604_edgeruntimeonly"
    product   = "iot_edge_vm_ubuntu"
    publisher = "microsoft_iot_edge"
  }

  tags = {
    environment = local.group_name
  }
}
