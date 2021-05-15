variable "name" {
  description = "Custom name for VNETs, gateways, and firewalls"
  type        = string
}

variable "prefix" {
  description = "Boolean to determine if name will be prepended with avx-"
  type        = bool
  default     = true
}

variable "suffix" {
  description = "Boolean to determine if name will be appended with -spoke"
  type        = bool
  default     = true
}

variable "region" {
  description = "The Azure region to deploy this module in"
  type        = string
}

variable "cidr" {
  description = "The CIDR range to be used for the VNET"
  type        = string
}

variable "account" {
  description = "The Azure account name, as known by the Aviatrix controller"
  type        = string
}

variable "instance_size" {
  description = "Azure Instance size for the Aviatrix gateways"
  type        = string
  default     = "Standard_B1ms"
}

variable "ha_gw" {
  description = "Boolean to determine if module will be deployed in HA or single mode"
  type        = bool
  default     = true
}

variable "active_mesh" {
  description = "Enables Aviatrix active mesh"
  type        = bool
  default     = true
}

variable "transit_gw" {
  description = "Transit gateway to attach spoke to"
  type        = string
}

variable "insane_mode" {
  description = "Set to true to enable Aviatrix high performance encryption."
  type        = bool
  default     = false
}

variable "attached" {
  description = "Set to false if you don't want to attach spoke to transit."
  type        = bool
  default     = true
}

variable "security_domain" {
  description = "Provide security domain name to which spoke needs to be deployed. Transit gateway mus tbe attached and have segmentation enabled."
  type        = string
  default     = ""
}

variable "single_az_ha" {
  description = "Set to true if Controller managed Gateway HA is desired"
  type        = bool
  default     = true
}

variable "single_ip_snat" {
  description = "Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8). Valid values: true, false."
  type        = bool
  default     = false
}

variable "customized_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be customized for the spoke VPC routes. When configured, it will replace all learned routes in VPC routing tables, including RFC1918 and non-RFC1918 CIDRs. It applies to this spoke gateway only​. Example: 10.0.0.0/116,10.2.0.0/16"
  type        = string
  default     = ""
}

variable "filtered_spoke_vpc_routes" {
  description = "A list of comma separated CIDRs to be filtered from the spoke VPC route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VPC routing tables as well as from spoke gateway’s routing table. It applies to this spoke gateway only. Example: 10.2.0.0/116,10.3.0.0/16"
  type        = string
  default     = ""
}

variable "included_advertised_spoke_routes" {
  description = "A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VPC. Example: 10.4.0.0/116,10.5.0.0/16"
  type        = string
  default     = ""
}

variable "vnet_subnet_pairs" {
  description = "Number of subnet pairs created in the vnet"
  type        = number
  default     = 2
}

variable "vnet_subnet_size" {
  description = "Size of each subnet cidr block in bits"
  type        = number
  default     = 28
}

variable "az_support" {
  description = "Set to true if the Azure region supports AZ's"
  type        = bool
  default     = true
}

variable "az1" {
  description = "AZ Zone to be used for GW deployment."
  type        = string
  default     = "az-1"
}

variable "az2" {
  description = "AZ Zone to be used for HAGW deployment."
  type        = string
  default     = "az-2"
}

locals {
  lower_name = replace(lower(var.name), " ", "-")
  prefix     = var.prefix ? "avx-" : ""
  suffix     = var.suffix ? "-spoke" : ""
  name       = "${local.prefix}${local.lower_name}${local.suffix}"
  cidrbits   = tonumber(split("/", var.cidr)[1])
  newbits    = 26 - local.cidrbits
  netnum     = pow(2, local.newbits)
  subnet     = var.insane_mode ? cidrsubnet(var.cidr, local.newbits, local.netnum - 2) : aviatrix_vpc.default.public_subnets[0].cidr
  ha_subnet  = var.insane_mode ? cidrsubnet(var.cidr, local.newbits, local.netnum - 1) : aviatrix_vpc.default.public_subnets[0].cidr
}
