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

resource "azurerm_monitor_data_collection_endpoint" "selenium_dce" {
  name                = "selenium-dce-udacity"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
}


resource "azapi_resource" "data_collection_logs_table" {
  name      = "SeleniumLogs_CL"
  parent_id = module.log_analytics.workspace_id
  type      = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"

  body = jsonencode({
    properties = {
      schema = {
        name = "SeleniumLogs_CL"
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
      retentionInDays      = 30
      totalRetentionInDays = 30
    }
  })
}


resource "azurerm_monitor_data_collection_rule" "selenium_dcr" {

  name                = "selenium-custom-log-dcr"
  location            = var.resource_location
  resource_group_name = data.azurerm_resource_group.main.name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.selenium_dce.id

	# Explicit dependency
	
  depends_on = [
    azurerm_monitor_data_collection_endpoint.selenium_dce,
	azapi_resource.data_collection_logs_table
  ]
  
  destinations {
    log_analytics {
      workspace_resource_id = module.log_analytics.workspace_id
      name                  = "law-destination"
    }
  }

  data_sources {
    log_file {
      name = "selenium-file-source"

      file_patterns = [
        "/var/log/selenium/*.log"
      ]

      format = "text"  # can be json, text, csv
	  
	  streams = [
		"Custom-${azapi_resource.data_collection_logs_table.name}"
      ]

      settings {
        text {
          record_start_timestamp_format = "ISO 8601"
        }
      }
    }
  }

  data_flow {
    streams      = ["Custom-${azapi_resource.data_collection_logs_table.name}"]
    destinations = ["law-destination"]
  }
}


resource "azurerm_virtual_machine_extension" "ama" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = data.azurerm_virtual_machine.selenium_vm.id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
  
  depends_on = [
    azurerm_monitor_data_collection_rule.selenium_dcr,
  ]
}



resource "azurerm_monitor_data_collection_rule_association" "dcr_vm" {
  name                    = "selenium-dcr-association"
  target_resource_id      = data.azurerm_virtual_machine.selenium_vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.selenium_dcr.id
  
  depends_on = [
    azurerm_virtual_machine_extension.ama
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "dce_vm" {
  name                         = "configurationAccessEndpoint"
  target_resource_id           = data.azurerm_virtual_machine.selenium_vm.id
  data_collection_endpoint_id  = azurerm_monitor_data_collection_endpoint.selenium_dce.id
  
    depends_on = [
    azurerm_virtual_machine_extension.ama
  ]
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
  
  scopes = [module.log_analytics.workspace_id]
  
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
