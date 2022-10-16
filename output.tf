output "private_resolver_id" {
  description = "The id of the resolver"
  value       = azapi_resource.private_resolver.id
}

output "private_resolver_name" {
  description = "The name of the resolver"
  value       = azapi_resource.private_resolver.name
}
