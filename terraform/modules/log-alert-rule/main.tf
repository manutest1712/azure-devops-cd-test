resource "azurerm_monitor_scheduled_query_rules_alert_v2" "log_alert" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  
  scopes = [var.workspace_id]

  enabled                = var.enabled
  severity               = var.severity
  evaluation_frequency   = var.evaluation_frequency
  window_duration        = var.window_duration

  criteria {
     query = <<-QUERY
		${var.table_name}
		| where RawData contains "Launching Chrome browser"
	  QUERY
    operator                 = var.operator
    threshold                = var.threshold
    time_aggregation_method  = var.aggregation
  }

  action {
    action_groups = [var.action_group_id]
  }
}