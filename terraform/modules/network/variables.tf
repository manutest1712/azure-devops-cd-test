variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "vnet_name" {
  description = "Name of Virtual Network"
  type        = string
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "subnet_prefix" {
  description = "Subnet CIDR block"
  type        = string
}

variable "nsg_name" {
  description = "Name of NSG"
  type        = string
}

variable "nic_name" {
  description = "Name of NIC"
  type        = string
}

variable "public_ip_id" {
  description = "Public IP resource ID"
  type        = string
}
