module "rg" {
  source = "registry.terraform.io/libre-devops/rg/azurerm"

  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-build" // rg-ldo-euw-dev-build
  location = local.location                                            // compares var.loc with the var.regions var to match a long-hand name, in this case, "euw", so "westeurope"
  tags     = local.tags

  #  lock_level = "CanNotDelete" // Do not set this value to skip lock
}

module "network" {
  source = "registry.terraform.io/libre-devops/network/azurerm"

  rg_name  = module.rg.rg_name // rg-ldo-euw-dev-build
  location = module.rg.rg_location
  tags     = local.tags

  vnet_name     = "vnet-${var.short}-${var.loc}-${terraform.workspace}-01" // vnet-ldo-euw-dev-01
  vnet_location = module.network.vnet_location

  address_space   = ["10.0.0.0/16"]
  subnet_prefixes = ["10.0.1.0/24", "10.0.17.0/24", "10.0.18.0/24"]
  subnet_names = [
    "sn1-${module.network.vnet_name}", "sn2-${module.network.vnet_name}", "sn3-${module.network.vnet_name}"
  ] //sn1-vnet-ldo-euw-dev-01
  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage"]
    // Adds extra subnet endpoints to sn1-vnet-ldo-euw-dev-01
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Sql"],
    // Adds extra subnet endpoints to sn2-vnet-ldo-euw-dev-01
    "sn3-${module.network.vnet_name}" = ["Microsoft.AzureActiveDirectory"]
    // Adds extra subnet endpoints to sn3-vnet-ldo-euw-dev-01
  }

  subnet_delegation = {
    "sn2-${module.network.vnet_name}" = {
      service_name    = "Microsoft.Network/dnsResolvers"
      service_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }

    "sn3-${module.network.vnet_name}" = {
      service_name    = "Microsoft.Network/dnsResolvers"
      service_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }
}

module "private_resolver" {
  source = "registry.terraform.io/libre-devops/dns-private-resolver/azapi"

  rg_name  = module.rg.rg_name // rg-ldo-euw-dev-build
  location = module.rg.rg_location
  tags     = local.tags
  rg_id    = module.rg.rg_id


  forwarding_rule_domain_name_target = "libredevops.org."
  forwarding_rule_name               = "dnspr-fowarding-rule-example"
  inbound_endpoint_name              = "dnspr-iep-example"
  outbound_endpoint_name             = "dnspr-oep-example"
  resolver_name                      = "lbdo-dnspr-01"
  resolver_vnet_link_name            = "lbdo-dnspr-link"
  rule_set_name                      = "lbdo-dnspr-rule-set"
  inbound_endpoint_subnet_id         = element(values(module.network.subnets_ids), 1)
  outbound_endpoint_subnet_id        = element(values(module.network.subnets_ids), 2)
  vnet_id                            = module.network.vnet_id

  target_dns_servers_info = [
    {
      ipAddress = "10.0.1.0"
      port      = 53
    }
  ]
}