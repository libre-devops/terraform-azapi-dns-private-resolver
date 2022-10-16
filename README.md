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
  subnet_names    = ["sn1-${module.network.vnet_name}", "sn2-${module.network.vnet_name}", "sn3-${module.network.vnet_name}"] //sn1-vnet-ldo-euw-dev-01
  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage"]                   // Adds extra subnet endpoints to sn1-vnet-ldo-euw-dev-01
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Sql"], // Adds extra subnet endpoints to sn2-vnet-ldo-euw-dev-01
    "sn3-${module.network.vnet_name}" = ["Microsoft.AzureActiveDirectory"]      // Adds extra subnet endpoints to sn3-vnet-ldo-euw-dev-01
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
}## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | >= 1.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| azapi_resource.forwarding_rule | resource |
| azapi_resource.inbound_endpoint | resource |
| azapi_resource.outbound_endpoint | resource |
| azapi_resource.private_resolver | resource |
| azapi_resource.resolver_vnet_link | resource |
| azapi_resource.rule_set | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_forwarding_rule_set"></a> [enable\_forwarding\_rule\_set](#input\_enable\_forwarding\_rule\_set) | Whether the forwarding rule resource should be created and enabled, defaults to true | `bool` | `true` | no |
| <a name="input_forwarding_rule_domain_name_target"></a> [forwarding\_rule\_domain\_name\_target](#input\_forwarding\_rule\_domain\_name\_target) | The name of the domain name the resolver is resolving for | `string` | n/a | yes |
| <a name="input_forwarding_rule_name"></a> [forwarding\_rule\_name](#input\_forwarding\_rule\_name) | The name of the forwarding rule | `string` | n/a | yes |
| <a name="input_inbound_endpoint_name"></a> [inbound\_endpoint\_name](#input\_inbound\_endpoint\_name) | The name of the inbound endpoint | `string` | n/a | yes |
| <a name="input_inbound_endpoint_subnet_id"></a> [inbound\_endpoint\_subnet\_id](#input\_inbound\_endpoint\_subnet\_id) | The subnet ID of for the inbound endpoint to be added to, must not collide with outbound endpoint subnet id | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_outbound_endpoint_name"></a> [outbound\_endpoint\_name](#input\_outbound\_endpoint\_name) | The name of the outbound endpoint | `string` | n/a | yes |
| <a name="input_outbound_endpoint_subnet_id"></a> [outbound\_endpoint\_subnet\_id](#input\_outbound\_endpoint\_subnet\_id) | The subnet ID for the NICs which are created with the VMs to be added to | `string` | n/a | yes |
| <a name="input_resolver_name"></a> [resolver\_name](#input\_resolver\_name) | The name of resolver | `string` | n/a | yes |
| <a name="input_resolver_vnet_link_name"></a> [resolver\_vnet\_link\_name](#input\_resolver\_vnet\_link\_name) | The name of the resolver's dns link | `string` | n/a | yes |
| <a name="input_rg_id"></a> [rg\_id](#input\_rg\_id) | The id of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_rule_set_name"></a> [rule\_set\_name](#input\_rule\_set\_name) | The name of the ruleset | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_target_dns_servers_info"></a> [target\_dns\_servers\_info](#input\_target\_dns\_servers\_info) | n/a | <pre>list(object({<br>    ipAddress = string #Make these optional objects after TF 1.4.x<br>    port      = number<br>  }))</pre> | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | ID of Vnet | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_resolver_id"></a> [private\_resolver\_id](#output\_private\_resolver\_id) | The id of the resolver |
| <a name="output_private_resolver_name"></a> [private\_resolver\_name](#output\_private\_resolver\_name) | The name of the resolver |
