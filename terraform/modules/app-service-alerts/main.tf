resource "azurerm_monitor_metric_alert" "app_alert" {
  name                = var.alert_name
  resource_group_name = var.resource_group_name
  scopes              = [var.app_id]
  description         = "Alert triggered when HTTP 404 errors detected"

  severity            = 3
  enabled             = true
  frequency           = "PT1M"
  window_size         = "PT5M"

  action {
    action_group_id = var.action_group_id
  }

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http404"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1
  }
}