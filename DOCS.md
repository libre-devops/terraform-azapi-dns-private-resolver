## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) | >= 1.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | 1.0.0 |

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
| <a name="output_private_resolver_inbound_endpoint_name"></a> [private\_resolver\_inbound\_endpoint\_name](#output\_private\_resolver\_inbound\_endpoint\_name) | The name of the inbound endpoint |
| <a name="output_private_resolver_name"></a> [private\_resolver\_name](#output\_private\_resolver\_name) | The name of the resolver |
| <a name="output_private_resolver_parent_id"></a> [private\_resolver\_parent\_id](#output\_private\_resolver\_parent\_id) | The name of the parent\_id |
| <a name="output_test_output"></a> [test\_output](#output\_test\_output) | n/a |
