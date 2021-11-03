# terraform-aviatrix-azure-spoke (Eskimoo Edit)

### Description
This module deploys a very simple spoke VNET.
Eskimoo added a VM to be deployed at init.

### Compatibility
Module version | Terraform version | Controller version | Terraform provider version
:--- | :--- | :--- | :---
v4.0.1 | 0.13 + 0.14 | >=6.4 | >=0.2.19
v4.0.0 | 0.13 + 0.14 | >=6.4 | >=0.2.19
v3.0.3 | 0.13 | >=6.3 | >=0.2.18
v3.0.2 | 0.13 | >=6.2 | >=0.2.17
v3.0.1 | 0.13 | >=6.2 | >=0.2.17 #Withdrawn due to issue
v3.0.0 | 0.13 | >=6.2 | >=0.2.17

### Diagram
<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-azure-spoke/blob/master/img/azure-ha.png?raw=true" height="250">

with ha_gw set to false, the following will be deployed:

<img src="https://github.com/terraform-aviatrix-modules/terraform-aviatrix-azure-spoke/blob/master/img/azure-single.png?raw=true" height="250">

### Usage Example
```
module "spoke_azure_1" {
  source  = "terraform-aviatrix-modules/azure-spoke/aviatrix"
  version = "4.0.1"

  name = "my-spoke"
  cidr = "10.1.0.0/20"
  region = "Japan East"
  account = "Azure"
  transit_gw = "tg-japan-east"
  security_domain = "blue"  
}
```

### Variables
The following variables are required:

key | value
:--- | :---
name | avx-\<name\>-spoke
region | AWS region to deploy this VNET in
cidr | What ip CIDR to use for this VNET (Not required when use_existing_vnet is true)
account | The account name as known by the Aviatrix controller
transit_gw | The name of the transit gateway we want to attach this spoke to. Not required when attached is set to false.

The following variables are optional:

key | default | value 
:---|:---|:---
instance_size | Standard_B1ms | The size of the Aviatrix spoke gateways. **Insane mode requires a minimum Standard_D3_v2 instance size**
ha_gw | true | Set to false if you only want to deploy a single Aviatrix spoke gateway
active_mesh | true | Set to false to disable active_mesh
insane_mode | false | Set to true to enable Aviatrix insane mode high-performance encryption
prefix | true | Boolean to enable prefix name with avx-
suffix | true | Boolean to enable suffix name with -spoke
attached | true | Set to false if you don't want to attach spoke to transit.
security_domain | | Provide security domain name to which spoke needs to be deployed. Transit gateway must be attached and have segmentation enabled.
single_az_ha | true | Set to false if Controller managed Gateway HA is desired
single_ip_snat | false | Specify whether to enable Source NAT feature in single_ip mode on the gateway or not. Please disable AWS NAT instance before enabling this feature. Currently only supports AWS(1) and AZURE(8)
customized_spoke_vpc_routes | | A list of comma separated CIDRs to be customized for the spoke VNET routes. When configured, it will replace all learned routes in VNET routing tables, including RFC1918 and non-RFC1918 CIDRs. Example: 10.0.0.0/116,10.2.0.0/16
filtered_spoke_vpc_routes | | A list of comma separated CIDRs to be filtered from the spoke VNET route table. When configured, filtering CIDR(s) or it’s subnet will be deleted from VNET routing tables as well as from spoke gateway’s routing table. Example: 10.2.0.0/116,10.3.0.0/16
included_advertised_spoke_routes | | A list of comma separated CIDRs to be advertised to on-prem as Included CIDR List. When configured, it will replace all advertised routes from this VNET. Example: 10.4.0.0/116,10.5.0.0/16
vnet_subnet_pairs | 2 | Number of Public/Private subnet pairs created in the VNET.
vnet_subnet_size | 28 | Size of the Public/Private subnets in the VNET.
az_support | true | Set to false if the Azure region does not support Availability Zones.
az1 | az-1 | AZ Zone to be used for Spoke GW
az2 | az-2 | AZ Zone to be used for HA Spoke GW
resource_group | null | Provide the name of an existing resource group.
tunnel_detection_time | null | The IPsec tunnel down detection time for the Spoke Gateway in seconds. Must be a number in the range [20-600]. Default is 60.
tags | null | Map of tags to assign to the gateway.
use_existing_vnet | false | Set to true to use an existing VNET in stead of having this module create one.
vnet_id | | VNET ID, for using an existing VNET. Format is: "<\vnet_name\>:\<resource_group_name\>"
gw_subnet | | Subnet CIDR, for using an existing VNET. Required when use_existing_vnet is enabled. Make sure this is a public subnet.
private_vpc_default_route | false | Program default route in VNET private route table.
skip_public_route_table_update | false | Skip programming VNET public route table.
auto_advertise_s2c_cidrs | false | Auto Advertise Spoke Site2Cloud CIDRs.
china | false | Set to true when deploying this module in Azure China
transit_gw_egress | | Add secondary transit to attach spoke to (e.g. for dual transit firenet). When segmentation is used, transit_gw MUST be used for east/west transit.
attached_gw_egress | true | Set to false if you don't want to attach spoke to transit_gw_egress.
transit_gw_route_tables | [] | A list of route tables to propagate routes to for transit_gw attachment.
transit_gw_egress_route_tables | [] | A list of route tables to propagate routes to for transit_gw_egress attachment.
inspection | false | Set to true to enable east/west Firenet inspection. Only valid when transit_gw is East/West transit Firenet

### Outputs
This module will return the following outputs:

key | description
:---|:---
vnet | The created VNET as an object with all of it's attributes (when use_existing_vnet is false). This was created using the aviatrix_vpc resource.
spoke_gateway | The created Aviatrix spoke gateway as an object with all of it's attributes.
