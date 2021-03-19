provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "DRDB" {
  name     = var.ResouceGroup
  location = var.Region
}

resource "azurerm_virtual_network" "VNET-DRDB" {
  name                = var.VnetName
  location            = azurerm_resource_group.DRDB.location
  resource_group_name = azurerm_resource_group.DRDB.name
  address_space       = ["192.168.0.0/24"]
  dns_servers         = ["192.168.0.4", "192.168.0.5"]
  
  subnet {
    name           = "SUBNET-DRDB"
    address_prefix = "192.168.0.0/24"
  }

  }