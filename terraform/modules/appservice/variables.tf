variable "app_name" { type = string }
variable "location" { type = string }
variable "resource_group_name" { type = string }
variable "service_plan_id" { type = string }

variable "always_on" {
  type    = bool
  default = false
}
