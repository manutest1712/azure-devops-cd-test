terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.70"
    }
	
	azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13.0"
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

provider "azapi" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}


data "azurerm_resource_group" "main" {
  name = "Azuredevops"
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


#############################################
# Log analytics for selinium logs
#############################################

data "azurerm_virtual_machine" "selenium_vm" {
  name                = "selenium-test-vm"
  resource_group_name = data.azurerm_resource_group.main.name
}

module "log_analytics" {
  source              = "../../modules/log-analytics-workspace"
  name                = "law-selenium-udacity"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
}


module "selenium_log_table" {
  source        = "../../modules/log-table"
  workspace_id  = module.log_analytics.workspace_id
  table_name    = "SeleniumLogs_CL"

  columns = [
    {
      name        = "TimeGenerated"
      type        = "datetime"
      description = "Log timestamp"
    },
    {
      name        = "RawData"
      type        = "string"
      description = "Entire raw log line"
    }
  ]
}

module "data_collection" {
  source              = "../../modules/data-collection-vm"
  name                = "selenium-dc"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name

  workspace_id        = module.log_analytics.workspace_id
  table_name          = module.selenium_log_table.name
  vm_id               = data.azurerm_virtual_machine.selenium_vm.id
  log_paths			  = ["/var/log/selenium/*.log"]

  table_dependency = module.selenium_log_table
  
   depends_on = [
    module.selenium_log_table
  ]
}


###############Alert Handling for the APP service ############################

module "action_group_app" {
  source              = "../../modules/email-action-group"
  name                = "ag-appservice-alerts"
  resource_group_name = data.azurerm_resource_group.main.name
  short_name          = "jmeter"
  email_address       = var.alert_email
}

module "app_service_alerts" {
  source               = "../../modules/app-service-alerts"
  alert_name           = "alert-demo-app-http404"
  resource_group_name  = data.azurerm_resource_group.main.name
  app_id               = module.web_app.app_id
  action_group_id      = module.action_group_app.action_group_id
}


###############Alert Handling for seleneum log ############################

module "action_group_selenium" {
  source              = "../../modules/email-action-group"
  name                = "ag-selenium-alerts"
  resource_group_name = data.azurerm_resource_group.main.name
  short_name          = "sel-alert"
  email_address       = var.alert_email
}

module "selenium_log_alert" {
  source              = "../../modules/log-alert-rule"
  name                = "alert-selenium-log-failure"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name

  workspace_id        = module.log_analytics.workspace_id
  action_group_id     = module.action_group_selenium.action_group_id
  table_name          = module.selenium_log_table.name

  depends_on = [
    module.selenium_log_table
  ]
}
