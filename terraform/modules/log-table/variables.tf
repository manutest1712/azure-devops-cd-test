variable "workspace_id" { type = string }
variable "table_name" { type = string }

variable "retention_in_days" {
  type    = number
  default = 30
}

variable "columns" {
  type = list(object({
    name        = string
    type        = string
    description = string
  }))
}