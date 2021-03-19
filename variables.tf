#Resource Group
variable "ResouceGroup" {
  default     = "RG-DRDB"

}

#Region
variable "Region" {
  default     = "West Europe"
}

#VNET Name
variable "VnetName" {
  default     = "VNET-DRDB"

}

variable "prefix" {
  default = "drdb"
}