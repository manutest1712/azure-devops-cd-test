output "name" {
  value = var.table_name
}

output "id" {
  value = azapi_resource.table.id
}