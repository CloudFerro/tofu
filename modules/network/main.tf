resource "openstack_networking_network_v2" "tenant_net" {
  name           = var.network_name
  admin_state_up = true
  region         = var.region
}

resource "openstack_networking_subnet_v2" "tenant_subnet" {
  count = length(var.subnets)

  name       = var.subnets[count.index].name
  network_id = openstack_networking_network_v2.tenant_net.id

  cidr       = var.subnets[count.index].cidr
  ip_version = var.subnets[count.index].ip_version

  enable_dhcp = var.subnets[count.index].enable_dhcp

  gateway_ip       = var.subnets[count.index].gateway_ip
  dns_nameservers  = var.subnets[count.index].dns_nameservers

  ipv6_address_mode = var.subnets[count.index].ipv6_address_mode
  ipv6_ra_mode      = var.subnets[count.index].ipv6_ra_mode

  dynamic "allocation_pool" {
    for_each = var.subnets[count.index].allocation_pools
    content {
      start = allocation_pool.value.start
      end   = allocation_pool.value.end
    }
  }

  region = var.region

  depends_on = [
    openstack_networking_network_v2.tenant_net
  ]
}

resource "openstack_networking_router_v2" "router" {
  name           = var.router_name
  admin_state_up = true

  external_network_id = var.external_network_id
  region              = var.region

  depends_on = [
    openstack_networking_subnet_v2.tenant_subnet
  ]
}

resource "openstack_networking_router_interface_v2" "router_int" {
  count = length(openstack_networking_subnet_v2.tenant_subnet)

  router_id = openstack_networking_router_v2.router.id
  subnet_id = openstack_networking_subnet_v2.tenant_subnet[count.index].id
  region    = var.region

  depends_on = [
    openstack_networking_router_v2.router
  ]
}

resource "openstack_networking_secgroup_v2" "standard" {
  name        = "standard"
  description = "Standard security group: SSH+ICMP ingress from anywhere, egress only to 10.0.0.0/24."
  delete_default_rules = true
  region = var.region
}

resource "openstack_networking_secgroup_rule_v2" "standard_ingress_ssh" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.standard.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.standard
  ]
}

resource "openstack_networking_secgroup_rule_v2" "standard_ingress_icmp" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.standard.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.standard
  ]
}

resource "openstack_networking_secgroup_rule_v2" "standard_egress_ipv4" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "10.0.0.0/24"
  security_group_id = openstack_networking_secgroup_v2.standard.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.standard
  ]
}
