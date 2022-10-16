# terraform-azurerm-linux-vm
This module follows the KISS design pattern compared to other modules in the market.  It does not try to do anything crazy and consider availability sets, scale sets etc, this will create you a VM based on some parameters you give it, nothing more, nothing less

```hcl

provider "azapi" {
  default_tags = local.tags
}

provider "azurerm" {
  features {
  }
}

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
  subnet_prefixes = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  subnet_names    = ["sn1-${module.network.vnet_name}", "sn2-${module.network.vnet_name}", "sn3-${module.network.vnet_name}"] //sn1-vnet-ldo-euw-dev-01
  subnet_service_endpoints = {
    "sn1-${module.network.vnet_name}" = ["Microsoft.Storage"]                   // Adds extra subnet endpoints to sn1-vnet-ldo-euw-dev-01
    "sn2-${module.network.vnet_name}" = ["Microsoft.Storage", "Microsoft.Sql"], // Adds extra subnet endpoints to sn2-vnet-ldo-euw-dev-01
    "sn3-${module.network.vnet_name}" = ["Microsoft.AzureActiveDirectory"]      // Adds extra subnet endpoints to sn3-vnet-ldo-euw-dev-01
  }
}

module "lnx_vm_simple" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location

  vm_amount          = 1
  vm_hostname        = "lnx${var.short}${var.loc}${terraform.workspace}"
  vm_size            = "Standard_B2ms"
  vm_os_simple       = "Ubuntu20.04"
  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.lnx_vm_simple.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key

  subnet_id            = element(values(module.network.subnets_ids), 0)
  availability_zone    = "alternate"
  storage_account_type = "Standard_LRS"
  identity_type        = "SystemAssigned"

  tags = module.rg.rg_tags
}

// Want to use this module without the SKU calculator? Try something like this:
module "lnx_vm_with_custom_image" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vm_amount   = 1
  vm_hostname = "vm${var.short}${var.loc}${terraform.workspace}" // vmldoeuwdev01
  vm_size     = "Standard_B2ms"

  use_simple_image = false
  source_image_reference = {
    publisher = "Oracle"
    offer     = "Oracle-Linux"
    sku       = "ol82"
    version   = "latest"
  }

  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.lnx_vm_with_custom_image.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key

  subnet_id            = element(values(module.network.subnets_ids), 0) // Places in sn1-vnet-ldo-euw-dev-01
  availability_zone    = "alternate"                                    // If more than 1 VM exists, places them in alterate zones, 1, 2, 3 then resetting.  If you want HA, use an availability set.
  storage_account_type = "Standard_LRS"
  identity_type        = "UserAssigned"
  identity_ids         = [data.azurerm_user_assigned_identity.mgmt_user_assigned_id.id]
}

// Sometimes you may want an image like the CIS images, these are part of a plan rather than the platform images.  You can use the ""registry.terraform.io/libre-devops/windows-os-plan-with-plan-calculator/azurerm""
module "lnx_vm_with_plan" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vm_amount   = 1
  vm_hostname = "jmp${var.short}${var.loc}${terraform.workspace}" // vmldoeuwdev01
  vm_size     = "Standard_B2ms"

  use_simple_image_with_plan = true
  vm_os_simple               = "CISDebian10L1"

  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.lnx_vm_with_plan.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key

  subnet_id            = element(values(module.network.subnets_ids), 0) // Places in sn1-vnet-ldo-euw-dev-01
  availability_zone    = "alternate"                                    // If more than 1 VM exists, places them in alterate zones, 1, 2, 3 then resetting.  If you want HA, use an availability set.
  storage_account_type = "Standard_LRS"
  identity_type        = "UserAssigned"
  identity_ids         = [data.azurerm_user_assigned_identity.mgmt_user_assigned_id.id]
}

// Don't want to use either? No problem.  Try this:
module "lnx_vm_with_custom_plan" {
  source = "registry.terraform.io/libre-devops/linux-vm/azurerm"

  rg_name  = module.rg.rg_name
  location = module.rg.rg_location
  tags     = module.rg.rg_tags

  vm_amount   = 1
  vm_hostname = "app${var.short}${var.loc}${terraform.workspace}" // appldoeuwdev01
  vm_size     = "Standard_B2ms"

  use_simple_image           = false
  use_simple_image_with_plan = false

  source_image_reference = {
    publisher = "center-for-internet-security-inc"
    offer     = "cis-centos-7-v2-1-1-l1"
    sku       = "cis-centos7-l1"
    version   = "latest"
  }

  plan = {
    name      = "cis-centos7-l1"
    product   = "cis-centos-7-v2-1-1-l1"
    publisher = "center-for-internet-security-inc"
  }

  vm_os_disk_size_gb = "127"

  asg_name = "asg-${element(regexall("[a-z]+", element(module.lnx_vm_with_custom_plan.vm_name, 0)), 0)}-${var.short}-${var.loc}-${terraform.workspace}-01" //asg-vmldoeuwdev-ldo-euw-dev-01 - Regex strips all numbers from string

  admin_username = "LibreDevOpsAdmin"
  admin_password = data.azurerm_key_vault_secret.mgmt_local_admin_pwd.value
  ssh_public_key = data.azurerm_ssh_public_key.mgmt_ssh_key.public_key

  subnet_id            = element(values(module.network.subnets_ids), 0) // Places in sn1-vnet-ldo-euw-dev-01
  availability_zone    = "alternate"                                    // If more than 1 VM exists, places them in alterate zones, 1, 2, 3 then resetting.  If you want HA, use an availability set.
  storage_account_type = "Standard_LRS"
  identity_type        = "UserAssigned"
  identity_ids         = [data.azurerm_user_assigned_identity.mgmt_user_assigned_id.id]
}

```

For a full example build, check out the [Libre DevOps Website](https://www.libredevops.org/quickstart/utils/terraform/using-lbdo-tf-modules-example.html)

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azapi_resource.forwarding_rule](https://registry.terraform.io/providers/hashicorp/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.inbound_endpoint](https://registry.terraform.io/providers/hashicorp/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.outbound_endpoint](https://registry.terraform.io/providers/hashicorp/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.private_resolver](https://registry.terraform.io/providers/hashicorp/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.resolver_vnet_link](https://registry.terraform.io/providers/hashicorp/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.rule_set](https://registry.terraform.io/providers/hashicorp/azapi/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_enable_forwarding_rule_set"></a> [enable\_forwarding\_rule\_set](#input\_enable\_forwarding\_rule\_set) | Whether the forwarding rule resource should be created and enabled, defaults to true | `bool` | `true` | no |
| <a name="input_forwarding_rule_domain_name_target"></a> [forwarding\_rule\_domain\_name\_target](#input\_forwarding\_rule\_domain\_name\_target) | The name of the domain name the resolver is resolving for | `string` | n/a | yes |
| <a name="input_forwarding_rule_name"></a> [forwarding\_rule\_name](#input\_forwarding\_rule\_name) | The name of the forwarding rule | `string` | n/a | yes |
| <a name="input_inbound_endpoint_name"></a> [inbound\_endpoint\_name](#input\_inbound\_endpoint\_name) | The name of the inbound endpoint | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The location for this resource to be put in | `string` | n/a | yes |
| <a name="input_outbound_endpoint_name"></a> [outbound\_endpoint\_name](#input\_outbound\_endpoint\_name) | The name of the outbound endpoint | `string` | n/a | yes |
| <a name="input_resolver_name"></a> [resolver\_name](#input\_resolver\_name) | The name of resolver | `string` | n/a | yes |
| <a name="input_resolver_vnet_link_name"></a> [resolver\_vnet\_link\_name](#input\_resolver\_vnet\_link\_name) | The name of the resolver's dns link | `string` | n/a | yes |
| <a name="input_rg_id"></a> [rg\_id](#input\_rg\_id) | The id of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists | `string` | n/a | yes |
| <a name="input_rule_set_name"></a> [rule\_set\_name](#input\_rule\_set\_name) | The name of the ruleset | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | The subnet ID for the NICs which are created with the VMs to be added to | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of the tags to use on the resources that are deployed with this module. | `map(string)` | <pre>{<br>  "source": "terraform"<br>}</pre> | no |
| <a name="input_target_dns_servers_info"></a> [target\_dns\_servers\_info](#input\_target\_dns\_servers\_info) | n/a | <pre>list(object({<br>    ipAddress = string #Make these optional objects after TF 1.4.x<br>    port      = number<br>  }))</pre> | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | ID of Vnet | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_resolver_id"></a> [private\_resolver\_id](#output\_private\_resolver\_id) | The id of the resolver |
| <a name="output_private_resolver_name"></a> [private\_resolver\_name](#output\_private\_resolver\_name) | The name of the resolver |
