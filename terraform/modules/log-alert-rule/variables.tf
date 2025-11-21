variable "name" {
  description = "Alert rule name"
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "workspace_id" {
  description = "Log Analytics Workspace ID"
  type        = string
}

variable "action_group_id" {
  description = "Action group to notify"
  type        = string
}

variable "table_name" {
  description = "Name of the Log Analytics custom table to query"
  type        = string
}

# Optional tuning parameters with defaults

variable "evaluation_frequency" {
  type    = string
  default = "PT5M"
}

variable "window_duration" {
  type    = string
  default = "PT5M"
}

variable "severity" {
  type    = number
  default = 1
}

variable "enabled" {
  type    = bool
  default = true
}

variable "operator" {
  type    = string
  default = "GreaterThan"
}

variable "threshold" {
  type    = number
  default = 0
}

variable "aggregation" {
  type    = string
  default = "Count"
}
