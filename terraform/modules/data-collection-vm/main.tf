resource "azurerm_monitor_data_collection_endpoint" "dce" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
}


resource "azurerm_monitor_data_collection_rule" "dcr" {
  name                        = "${var.name}-dcr"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id

  depends_on = [ var.table_dependency ]

  destinations {
    log_analytics {
      workspace_resource_id = var.workspace_id
      name                  = "law-destination"
    }
  }

  data_sources {
    log_file {
      name         = "selenium-file-source"
      file_patterns = var.log_paths
      format        = "text"
      streams       = ["Custom-${var.table_name}"]

      settings {
        text {
          record_start_timestamp_format = "ISO 8601"
        }
      }
    }
  }

  data_flow {
    streams      = ["Custom-${var.table_name}"]
    destinations = ["law-destination"]
  }
}


resource "azurerm_virtual_machine_extension" "ama" {
  name                 = "AzureMonitorLinuxAgent"
  virtual_machine_id   = var.vm_id
  publisher            = "Microsoft.Azure.Monitor"
  type                 = "AzureMonitorLinuxAgent"
  type_handler_version = "1.0"
  auto_upgrade_minor_version = true
}


resource "azurerm_monitor_data_collection_rule_association" "dcr_vm" {
  name                    = "${var.name}-dcr-association"
  target_resource_id      = var.vm_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr.id
  depends_on = [
	azurerm_monitor_data_collection_rule.dcr,
    azurerm_virtual_machine_extension.ama
  ]
}

resource "azurerm_monitor_data_collection_rule_association" "dce_vm" {
  name                        = "endpoint-association"
  target_resource_id          = var.vm_id
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  depends_on = [
	azurerm_monitor_data_collection_endpoint.dce,
    azurerm_virtual_machine_extension.ama
  ]
}