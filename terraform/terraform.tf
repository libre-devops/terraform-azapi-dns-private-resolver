terraform {
  #Use the latest by default, uncomment below to pin or use hcl.lck
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      #      configuration_aliases = [azurerm.default-provider]
      #      version = "~> 2.68.0"
    }
    azapi = {
      source  = "registry.terraform.io/Azure/azapi"
      version = ">= 1.0.0"
    }
  }
  backend "azurerm" {
  }
}