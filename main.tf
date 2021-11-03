# Create an Azure VNet
resource "aviatrix_vpc" "default" {
  count                = var.use_existing_vnet ? 0 : 1
  cloud_type           = local.cloud_type
  account_name         = var.account
  region               = var.region
  name                 = local.name
  cidr                 = var.cidr
  aviatrix_transit_vpc = false
  aviatrix_firenet_vpc = false
  num_of_subnet_pairs  = var.vnet_subnet_pairs
  subnet_size          = var.vnet_subnet_size
  resource_group       = var.resource_group
}

resource "aviatrix_spoke_gateway" "default" {
  cloud_type                            = local.cloud_type
  account_name                          = var.account
  gw_name                               = local.name
  vpc_id                                = var.use_existing_vnet ? var.vnet_id : aviatrix_vpc.default[0].vpc_id
  vpc_reg                               = var.region
  gw_size                               = var.instance_size
  ha_gw_size                            = var.ha_gw ? var.instance_size : null
  subnet                                = local.subnet
  ha_subnet                             = var.ha_gw ? local.ha_subnet : null
  insane_mode                           = var.insane_mode
  enable_active_mesh                    = var.active_mesh
  manage_transit_gateway_attachment     = false
  single_az_ha                          = var.single_az_ha
  single_ip_snat                        = var.single_ip_snat
  customized_spoke_vpc_routes           = var.customized_spoke_vpc_routes
  filtered_spoke_vpc_routes             = var.filtered_spoke_vpc_routes
  included_advertised_spoke_routes      = var.included_advertised_spoke_routes
  zone                                  = var.az_support ? var.az1 : null
  ha_zone                               = var.ha_gw ? (var.az_support ? var.az2 : null) : null
  enable_private_vpc_default_route      = var.private_vpc_default_route
  enable_skip_public_route_table_update = var.skip_public_route_table_update
  enable_auto_advertise_s2c_cidrs       = var.auto_advertise_s2c_cidrs
  tunnel_detection_time                 = var.tunnel_detection_time
  tags                                  = var.tags
}

resource "aviatrix_spoke_transit_attachment" "default" {
  count           = var.attached ? 1 : 0
  spoke_gw_name   = aviatrix_spoke_gateway.default.gw_name
  transit_gw_name = var.transit_gw
  route_tables    = var.transit_gw_route_tables
}

resource "aviatrix_spoke_transit_attachment" "transit_gw_egress" {
  count           = length(var.transit_gw_egress) > 0 ? (var.attached_gw_egress ? 1 : 0) : 0
  spoke_gw_name   = aviatrix_spoke_gateway.default.gw_name
  transit_gw_name = var.transit_gw_egress
  route_tables    = var.transit_gw_egress_route_tables
}

resource "aviatrix_segmentation_security_domain_association" "default" {
  count                = var.attached ? (length(var.security_domain) > 0 ? 1 : 0) : 0 #Only create resource when attached and security_domain is set.
  transit_gateway_name = var.transit_gw
  security_domain_name = var.security_domain
  attachment_name      = aviatrix_spoke_gateway.default.gw_name
  depends_on           = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition
}

resource "aviatrix_transit_firenet_policy" "default" {
  count                        = var.inspection ? (var.attached ? 1 : 0) : 0
  transit_firenet_gateway_name = var.transit_gw
  inspected_resource_name      = "SPOKE:${aviatrix_spoke_gateway.default.gw_name}"
  depends_on                   = [aviatrix_spoke_transit_attachment.default] #Let's make sure this cannot create a race condition
}













resource "azurerm_resource_group" "example" {
  name     = "RGEskTfm"
  location = "West Europe"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name


  ip_configuration {
    name                          = "internal"
    subnet_id                     = aviatrix_vpc.default[0].subnets[2].subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id

    
  }
}

resource "azurerm_public_ip" "example" {
  name                = "EskimooPublicIp1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  
  allocation_method   = "Dynamic"

  }


resource "azurerm_linux_virtual_machine" "example" {
  name                = "EskimooTest"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
 
  size                = "Standard_F2"
  disable_password_authentication = false
  admin_username      = "adminuser"
  admin_password = "Password123!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
}




# resource "azurerm_virtual_network" "example" {
#   name                = "example-network"
#   address_space       = ["10.78.0.0/20"]
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
# }

# resource "azurerm_subnet" "example" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.78.0.0/24"]
# }

