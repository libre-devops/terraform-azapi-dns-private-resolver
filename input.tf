variable "enable_forwarding_rule_set" {
  type        = bool
  description = "Whether the forwarding rule resource should be created and enabled, defaults to true"
  default     = true
}

variable "forwarding_rule_domain_name_target" {
  type        = string
  description = "The name of the domain name the resolver is resolving for"
}

variable "forwarding_rule_name" {
  type        = string
  description = "The name of the forwarding rule"
}

variable "inbound_endpoint_name" {
  type        = string
  description = "The name of the inbound endpoint"
}

variable "inbound_endpoint_subnet_id" {
  type        = string
  description = "The subnet ID of for the inbound endpoint to be added to, must not collide with outbound endpoint subnet id"
}

variable "location" {
  description = "The location for this resource to be put in"
  type        = string
}

variable "outbound_endpoint_name" {
  type        = string
  description = "The name of the outbound endpoint"
}

variable "outbound_endpoint_subnet_id" {
  type        = string
  description = "The subnet ID for the NICs which are created with the VMs to be added to"
}

variable "resolver_name" {
  type        = string
  description = "The name of resolver"
}

variable "resolver_vnet_link_name" {
  type        = string
  description = "The name of the resolver's dns link"
}

variable "rg_id" {
  description = "The id of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
}

variable "rg_name" {
  description = "The name of the resource group, this module does not create a resource group, it is expecting the value of a resource group already exists"
  type        = string
  validation {
    condition     = length(var.rg_name) > 1 && length(var.rg_name) <= 24
    error_message = "Resource group name is not valid."
  }
}

variable "rule_set_name" {
  type        = string
  description = "The name of the ruleset"
}

variable "tags" {
  type        = map(string)
  description = "A map of the tags to use on the resources that are deployed with this module."

  default = {
    source = "terraform"
  }
}

variable "target_dns_servers_info" {
  type = list(object({
    ipAddress = string #Make these optional objects after TF 1.4.x
    port      = number
  }))
}

variable "vnet_id" {
  description = "ID of Vnet"
  type        = string
}
