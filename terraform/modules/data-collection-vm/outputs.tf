output "dc_endpoint_id" {
  description = "Resource ID of the Azure Monitor Data Collection Endpoint"
  value       = azurerm_monitor_data_collection_endpoint.dce.id
}

output "dc_rule_id" {
  description = "Resource ID of the Azure Monitor Data Collection Rule"
  value       = azurerm_monitor_data_collection_rule.dcr.id
}

output "vm_extension_id" {
  description = "Resource ID for the AMA Virtual Machine extension"
  value       = azurerm_virtual_machine_extension.ama.id
}

output "dcr_vm_association_id" {
  description = "Resource ID of the DCR → VM association"
  value       = azurerm_monitor_data_collection_rule_association.dcr_vm.id
}

output "dce_vm_association_id" {
  description = "Resource ID of the DCE → VM association"
  value       = azurerm_monitor_data_collection_rule_association.dce_vm.id
}