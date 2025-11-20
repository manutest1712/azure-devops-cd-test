terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
  }
  
   backend "azurerm" {
    resource_group_name  = "Azuredevops"
    storage_account_name = "tfstateaccount2025manu"
    container_name       = "tfstate"
    key                  = "test.terraform.tfstate"
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
  app_name            = "demo-app-udacity"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  service_plan_id     = module.service_plan.service_plan_id

  always_on = false
}

###############Alert Handling for the APP service ############################

resource "azurerm_monitor_action_group" "jmeter_action_group" {
  name                = "ag-jmeter-alerts"
  resource_group_name = data.azurerm_resource_group.main.name
  short_name          = "jmeter"

  email_receiver {
    name          = "alert-email"
    email_address = var.alert_email
  }
}


resource "azurerm_monitor_metric_alert" "app_service_alert_404" {
  name                = "alert-demo-app-http404"
  resource_group_name = data.azurerm_resource_group.main.name
  scopes              = [module.web_app.app_id]   # 🔥 IMPORTANT
  description         = "Alert when App Service returns HTTP 404"

  severity = 3
  enabled  = true

  frequency 		   = "PT1M"   # check every 1 minute
  window_size          = "PT5M"   # evaluate last 5 minute

  action {
    action_group_id = azurerm_monitor_action_group.jmeter_action_group.id
  }

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http404"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1   # triggers when > 1 error occurs
    # skip_metric_validation = true  # enable if Terraform fails metric verification
  }
}


###############Alert Handling for seleneum log ############################
data "azurerm_log_analytics_workspace" "law" {
  name                = "law-selenium-udacity-x"
  resource_group_name = data.azurerm_resource_group.main.name
}


resource "azurerm_monitor_action_group" "seleneum_action_group" {
  name                = "ag-selenium-alerts"
  resource_group_name = data.azurerm_resource_group.main.name
  short_name          = "sel-alert"

  email_receiver {
    name          = "alert-email"
    email_address = var.alert_email
  }
}

resource "azurerm_monitor_scheduled_query_rules_alert_v2" "selenium_fail_alert" {
  name                = "alert-selenium-log-failure"
  resource_group_name = data.azurerm_resource_group.main.name
  location            = var.resource_location
  
  scopes = [data.azurerm_log_analytics_workspace.law.id]
  
  evaluation_frequency = "PT5M"
  window_duration      = "PT5M"

  enabled     = true
  severity    = 1
  criteria {
    # The KQL Query to run
    query = <<-QUERY
      SeleniumLogs_CL
      | where RawData contains "Launching Chrome browser"
    QUERY

    # Trigger logic: If Count > 0
    operator                = "GreaterThan"
    threshold               = 0
    time_aggregation_method = "Count"
    
  }
  
  # Link the Alert to the Action Group created above
  action {
    action_groups = [azurerm_monitor_action_group.seleneum_action_group.id]
  }
}
