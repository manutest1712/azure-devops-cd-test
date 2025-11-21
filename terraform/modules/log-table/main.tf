terraform {
  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = "~> 1.13.0"
    }
  }
}

resource "azapi_resource" "table" {
  name       = var.table_name
  parent_id  = var.workspace_id
  type       = "Microsoft.OperationalInsights/workspaces/tables@2022-10-01"

  body = jsonencode({
    properties = {
      schema = {
        name = var.table_name
        columns = var.columns
      }
      retentionInDays      = var.retention_in_days
      totalRetentionInDays = var.retention_in_days
    }
  })
}