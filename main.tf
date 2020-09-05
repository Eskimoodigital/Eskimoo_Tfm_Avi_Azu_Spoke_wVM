# Create an Azure VNet
resource "aviatrix_vpc" "default" {
  cloud_type           = 8
  account_name         = var.account
  region               = var.region
  name                 = "avx-${var.name}-spoke"
  cidr                 = var.cidr
  aviatrix_firenet_vpc = false
}

resource "aviatrix_spoke_gateway" "single" {
  count              = var.ha_gw ? 0 : 1
  cloud_type         = 8
  account_name       = var.account
  gw_name            = "avx-${var.name}-spoke"
  vpc_id             = aviatrix_vpc.default.vpc_id
  vpc_reg            = var.region
  gw_size            = var.instance_size
  subnet             = var.insane_mode ? cidrsubnet(aviatrix_vpc.default.cidr, 3, 6) : aviatrix_vpc.default.subnets[0].cidr
  insane_mode        = var.insane_mode
  enable_active_mesh = var.active_mesh
  transit_gw         = var.transit_gw
}

resource "aviatrix_spoke_gateway" "ha" {
  count              = var.ha_gw ? 1 : 0
  cloud_type         = 8
  account_name       = var.account
  gw_name            = "avx-${var.name}-spoke"
  vpc_id             = aviatrix_vpc.default.vpc_id
  vpc_reg            = var.region
  gw_size            = var.instance_size
  ha_gw_size         = var.instance_size
  subnet             = var.insane_mode ? cidrsubnet(aviatrix_vpc.default.cidr, 3, 6) : aviatrix_vpc.default.subnets[0].cidr
  ha_subnet          = var.insane_mode ? cidrsubnet(aviatrix_vpc.default.cidr, 3, 7) : aviatrix_vpc.default.subnets[0].cidr
  insane_mode        = var.insane_mode
  enable_active_mesh = var.active_mesh
  transit_gw         = var.transit_gw
}
