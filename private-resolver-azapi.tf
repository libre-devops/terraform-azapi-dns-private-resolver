resource "azapi_resource" "private_resolver" {
  type      = "Microsoft.Network/dnsResolvers@2020-04-01-preview"
  name      = var.resolver_name
  parent_id = var.rg_id
  location  = var.location

  body = jsonencode({
    properties = {
      virtualNetwork = {
        id = var.vnet_id
      }
    }
  })

  response_export_values = ["properties.virtualnetwork.id"]
}

resource "azapi_resource" "inbound_endpoint" {
  type      = "Microsoft.Network/dnsResolvers/inboundEndpoints@2020-04-01-preview"
  name      = var.inbound_endpoint_name
  parent_id = azapi_resource.private_resolver.id
  location  = azapi_resource.private_resolver.location

  body = jsonencode({
    properties = {
      ipConfigurations = [{ subnet = { id = var.subnet_id } }]
    }
  })

  response_export_values = ["properties.ipconfiguration"]
  depends_on = [
    azapi_resource.private_resolver
  ]
}

resource "azapi_resource" "outbound_endpoint" {
  type      = "Microsoft.Network/dnsResolvers/outboundEndpoints@2020-04-01-preview"
  name      = var.outbound_endpoint_name
  parent_id = azapi_resource.private_resolver.id
  location  = azapi_resource.private_resolver.location

  body = jsonencode({
    properties = {
      subnet = {
        id = var.subnet_id
      }
    }
  })

  response_export_values = ["properties.subnet"]
  depends_on = [
    azapi_resource.private_resolver
  ]
}

resource "azapi_resource" "rule_set" {
  type      = "Microsoft.Network/dnsForwardingRulesets@2020-04-01-preview"
  name      = var.rule_set_name
  parent_id = var.rg_id
  location  = var.location
  tags      = var.tags

  body = jsonencode({
    properties = {
      dnsResolverOutboundEndpoints = [{
        id = azapi_resource.outbound_endpoint.id
      }]
    }
  })
  depends_on = [
    azapi_resource.private_resolver
  ]
}

resource "azapi_resource" "resolver_vnet_link" {
  type      = "Microsoft.Network/dnsForwardingRulesets/virtualNetworkLinks@2020-04-01-preview"
  name      = var.resolver_vnet_link_name
  parent_id = azapi_resource.rule_set.id

  body = jsonencode({
    properties = {
      virtualNetwork = {
        id = var.vnet_id
      }
    }
  })
  depends_on = [
    azapi_resource.private_resolver
  ]
}

resource "azapi_resource" "forwarding_rule" {
  count     = var.enable_forwarding_rule_set ? 1 : 0
  type      = "Microsoft.Network/dnsForwardingRulesets/forwardingRules@2020-04-01-preview"
  name      = var.forwarding_rule_name
  parent_id = azapi_resource.rule_set.id

  body = jsonencode({
    properties = {
      domainName          = var.forwarding_rule_domain_name_target
      forwardingRuleState = var.enable_forwarding_rule_set == true ? "Enabled" : "Disabled"
      targetDnsServers    = var.target_dns_servers_info
    }
  })
  depends_on = [
    azapi_resource.private_resolver
  ]
}