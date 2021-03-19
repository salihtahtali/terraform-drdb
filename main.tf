provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "DRDB" {
  name     = var.ResouceGroup
  location = var.Region
}

#Creating Vnet and Subnet
resource "azurerm_virtual_network" "VNET-DRDB" {
  name                = var.VnetName
  location            = azurerm_resource_group.DRDB.location
  resource_group_name = azurerm_resource_group.DRDB.name
  address_space       = ["192.168.0.0/24"]
  dns_servers         = ["192.168.0.4", "192.168.0.5"]

  }

resource "azurerm_subnet" "drdb-subnet" {
  name                 = "SUBNET-DRDB"
  resource_group_name  = azurerm_resource_group.DRDB.name
  virtual_network_name = azurerm_virtual_network.VNET-DRDB.name
  address_prefixes     = ["192.168.0.0/24"]
}

#Public IP Addresses for DRDB01

resource "azurerm_public_ip" "DRDB01" {
  name                = "Public-ip-drdb01"
  resource_group_name = azurerm_resource_group.DRDB.name
  location            = azurerm_resource_group.DRDB.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}
  
#Public IP Addresses for DRDB02
resource "azurerm_public_ip" "DRDB02" {
  name                = "Public-ip-drdb02"
  resource_group_name = azurerm_resource_group.DRDB.name
  location            = azurerm_resource_group.DRDB.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

#Network Interface for DRDB01


resource "azurerm_network_interface" "drdb01nic" {
  name                = "drdb01nic"
  location            = azurerm_resource_group.DRDB.location
  resource_group_name = azurerm_resource_group.DRDB.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.drdb-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.0.10"
    public_ip_address_id          = azurerm_public_ip.DRDB01.id

  }
}

#Network Interface for DRDB02

resource "azurerm_network_interface" "drdb02nic" {
  name                = "drdb02nic"
  location            = azurerm_resource_group.DRDB.location
  resource_group_name = azurerm_resource_group.DRDB.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.drdb-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.0.20"
    public_ip_address_id          = azurerm_public_ip.DRDB02.id

  }
}


resource "azurerm_virtual_machine" "drdbvm01" {
  name                  = "DRDB01"
  location              = azurerm_resource_group.DRDB.location
  resource_group_name   = azurerm_resource_group.DRDB.name
  network_interface_ids = [azurerm_network_interface.drdb01nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
      }
       storage_os_disk {
    name              = "drdb01-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "drdb01"
    admin_username = "drdb01admin"
    admin_password = "drdb01adminPassword1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_machine" "drdbvm02" {
  name                  = "DRDB02"
  location              = azurerm_resource_group.DRDB.location
  resource_group_name   = azurerm_resource_group.DRDB.name
  network_interface_ids = [azurerm_network_interface.drdb02nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
      }
       storage_os_disk {
    name              = "drdb02-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "drdb02"
    admin_username = "drdb02admin"
    admin_password = "drdb02adminPassword1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }
}

