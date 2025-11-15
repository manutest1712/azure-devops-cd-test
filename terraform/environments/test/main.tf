terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

data "azurerm_resource_group" "main" {
  name = "Azuredevops"
}


# Public IP
/*resource "azurerm_public_ip" "demo_vm_ip" {
  name                = "demo-vm-public-ip"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
*/

module "public_ip" {
  source              = "../../modules/public-ip"
  name                = "demo-vm-public-ip"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "network" {
  source = "../../modules/network"

  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name

  vnet_name          = "demo-vnet"
  vnet_address_space = "10.90.0.0/16"

  subnet_name   = "demo-subnet"
  subnet_prefix = "10.90.1.0/24"

  nsg_name = "demo-nsg"

  nic_name = "demo-nic"

  public_ip_id = module.public_ip.public_ip_id
}


module "vm" {
  source = "../../modules/vm"

  vm_name            = "demo-vm"
  location           = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name

  vm_size = "Standard_B1s"
  nic_id  = module.network.nic_id

  admin_username = "ManuMP"
  admin_password = "Staple17121980@"

  disable_password_authentication = false
}


module "service_plan" {
  source              = "../../modules/appservice-plan"
  name                = "demo-asp"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  sku_name            = "F1"
  os_type             = "Linux"
}


module "web_app" {
  source              = "../../modules/appservice"
  app_name            = "demo-app-udacity-xx"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  service_plan_id     = module.service_plan.service_plan_id

  always_on = false
}