provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "drbd" {
  name     = var.ResouceGroup
  location = var.Region
}

#Creating Vnet and Subnet
resource "azurerm_virtual_network" "VNET-drbd" {
  name                = var.VnetName
  location            = azurerm_resource_group.drbd.location
  resource_group_name = azurerm_resource_group.drbd.name
  address_space       = ["192.168.0.0/24"]

  }

resource "azurerm_subnet" "drbd-subnet" {
  name                 = "SUBNET-drbd"
  resource_group_name  = azurerm_resource_group.drbd.name
  virtual_network_name = azurerm_virtual_network.VNET-drbd.name
  address_prefixes     = ["192.168.0.0/24"]
}

#Public IP Addresses for drbd01

resource "azurerm_public_ip" "drbd01" {
  name                = "Public-ip-drbd01"
  resource_group_name = azurerm_resource_group.drbd.name
  location            = azurerm_resource_group.drbd.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}
  
#Public IP Addresses for drbd02
resource "azurerm_public_ip" "drbd02" {
  name                = "Public-ip-drbd02"
  resource_group_name = azurerm_resource_group.drbd.name
  location            = azurerm_resource_group.drbd.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

#Network Interface for drbd01


resource "azurerm_network_interface" "drbd01nic" {
  name                = "drbd01nic"
  location            = azurerm_resource_group.drbd.location
  resource_group_name = azurerm_resource_group.drbd.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.drbd-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.0.10"
    public_ip_address_id          = azurerm_public_ip.drbd01.id

  }
}

#Network Interface for drbd02

resource "azurerm_network_interface" "drbd02nic" {
  name                = "drbd02nic"
  location            = azurerm_resource_group.drbd.location
  resource_group_name = azurerm_resource_group.drbd.name

  ip_configuration {
    name                          = "testconfiguration2"
    subnet_id                     = azurerm_subnet.drbd-subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "192.168.0.20"
    public_ip_address_id          = azurerm_public_ip.drbd02.id

  }
}


resource "azurerm_virtual_machine" "drbdvm01" {
  name                  = "drbd01"
  location              = azurerm_resource_group.drbd.location
  resource_group_name   = azurerm_resource_group.drbd.name
  network_interface_ids = [azurerm_network_interface.drbd01nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
      }
       storage_os_disk {
    name              = "drbd01-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "drbd01"
    admin_username = "drbd01admin"
    admin_password = "drbd01adminPassword1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }
}

resource "azurerm_virtual_machine" "drbdvm02" {
  name                  = "drbd02"
  location              = azurerm_resource_group.drbd.location
  resource_group_name   = azurerm_resource_group.drbd.name
  network_interface_ids = [azurerm_network_interface.drbd02nic.id]
  vm_size               = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
      }
       storage_os_disk {
    name              = "drbd02-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "drbd02"
    admin_username = "drbd02admin"
    admin_password = "drbd02adminPassword1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "test"
  }
}

#Additional Disks for drbd01

resource "azurerm_managed_disk" "drbd01" {
  name                 = "drbd01-disk02"
  location             = azurerm_resource_group.drbd.location
  resource_group_name  = azurerm_resource_group.drbd.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 50
}

resource "azurerm_virtual_machine_data_disk_attachment" "drbd01" {
  managed_disk_id    = azurerm_managed_disk.drbd01.id
  virtual_machine_id = azurerm_virtual_machine.drbdvm01.id
  lun                = "10"
  caching            = "ReadWrite"
}

#Additional Disks for drbd02

resource "azurerm_managed_disk" "drbd02" {
  name                 = "drbd02-disk02"
  location             = azurerm_resource_group.drbd.location
  resource_group_name  = azurerm_resource_group.drbd.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 50
}

resource "azurerm_virtual_machine_data_disk_attachment" "drbd02" {
  managed_disk_id    = azurerm_managed_disk.drbd02.id
  virtual_machine_id = azurerm_virtual_machine.drbdvm02.id
  lun                = "10"
  caching            = "ReadWrite"
}