output "private_resolver_id" {
  description = "The id of the resolver"
  value       = azapi_resource.private_resolver.id
}

output "private_resolver_inbound_endpoint_name" {
  description = "The name of the inbound endpoint"
  value       = azapi_resource.inbound_endpoint.name
}

output "private_resolver_name" {
  description = "The name of the resolver"
  value       = azapi_resource.private_resolver.name
}

output "private_resolver_parent_id" {
  description = "The name of the parent_id"
  value       = azapi_resource.private_resolver.parent_id
}
