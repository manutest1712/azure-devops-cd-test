variable "name" {
  description = "Base name for Data Collection Endpoint and associated resources"
  type        = string
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for deployment"
  type        = string
}

variable "workspace_id" {
  description = "Log Analytics Workspace resource ID"
  type        = string
}

variable "table_name" {
  description = "Custom Log Analytics Table name for the stream"
  type        = string
}


variable "vm_id" {
  description = "Resource ID of the Virtual Machine receiving the agent configuration"
  type        = string
}

variable "table_dependency" {
  description = "Explicit dependency placeholder (module/table reference)"
  type        = any
  default     = null
}


variable "log_paths" {
  type    = list(string)
}

