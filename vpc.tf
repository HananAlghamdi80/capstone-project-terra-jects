resource "alicloud_vpc" "vpc" {
  vpc_name   = "myvpc"
  cidr_block = "10.0.0.0/8"
}

data "alicloud_zones" "availability_zones" {
  available_resource_creation = "VSwitch"
}

resource "alicloud_vswitch" "public" {
  vswitch_name = "public"
  cidr_block   = "10.0.1.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones.0.id
}

resource "alicloud_route_table" "public" {
  description      = "Public"
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "public"
  associate_type   = "VSwitch"
}



resource "alicloud_vswitch" "public-b" {
  vswitch_name = "public"
  cidr_block   = "10.0.3.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones.1.id
}

resource "alicloud_vswitch" "private" {
  vswitch_name = "private"
  cidr_block   = "10.0.2.0/24"
  vpc_id       = alicloud_vpc.vpc.id
  zone_id      = data.alicloud_zones.availability_zones.zones.0.id
}


resource "alicloud_nat_gateway" "default" {
  vpc_id           = alicloud_vpc.vpc.id
  nat_gateway_name = "http"
  payment_type     = "PayAsYouGo"
  vswitch_id       = alicloud_vswitch.public.id
  nat_type         = "Enhanced"
}

resource "alicloud_eip_address" "nat" {
  description          = "nat"
  address_name         = "nat"
  netmode              = "public"
  bandwidth            = "100"
  payment_type         = "PayAsYouGo"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "nat" {
  allocation_id = alicloud_eip_address.nat.id
  instance_id   = alicloud_nat_gateway.default.id
  instance_type = "Nat"
}

resource "alicloud_snat_entry" "http_private" {
  snat_table_id     = alicloud_nat_gateway.default.snat_table_ids
  source_vswitch_id = alicloud_vswitch.private.id
  snat_ip           = alicloud_eip_address.nat.ip_address
}

resource "alicloud_route_table" "private" {
  description      = "Private"
  vpc_id           = alicloud_vpc.vpc.id
  route_table_name = "private"
  associate_type   = "VSwitch"
}

resource "alicloud_route_entry" "nat" {
  route_table_id        = alicloud_route_table.private.id
  destination_cidrblock = "0.0.0.0/0"
  nexthop_type          = "NatGateway"
  nexthop_id            = alicloud_nat_gateway.default.id
}



resource "alicloud_route_table_attachment" "public" {
  vswitch_id     = alicloud_vswitch.public.id
  route_table_id = alicloud_route_table.public.id
}


resource "alicloud_route_table_attachment" "private" {
  vswitch_id     = alicloud_vswitch.private.id
  route_table_id = alicloud_route_table.private.id
}
