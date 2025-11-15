variable "vm_name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "nic_id" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type = string
  description = "Admin password for VM"
}

variable "disable_password_authentication" {
  type    = bool
  default = false
  description = "Set to true to disable password login and use SSH only"
}

variable "ssh_public_key_path" {
  type        = string
  default     = ""
  description = "Path to SSH public key file. Leave empty to disable SSH."
}
