locals {
  ingress_tcp_rules = {
    for pair in setproduct(var.allowed_ingress_cidrs, var.allowed_ingress_tcp_ports) :
    "${pair[0]}-tcp-${pair[1]}" => {
      cidr = pair[0]
      port = pair[1]
    }
  }

  ingress_udp_rules = {
    for pair in setproduct(var.allowed_ingress_cidrs, var.allowed_ingress_udp_ports) :
    "${pair[0]}-udp-${pair[1]}" => {
      cidr = pair[0]
      port = pair[1]
    }
  }

  ingress_icmp_rules = {
    for cidr in var.allowed_ingress_cidrs :
    cidr => {
      cidr = cidr
    }
  }

  egress_rules = {
    for cidr in var.allowed_egress_cidrs :
    cidr => {
      cidr = cidr
    }
  }
}

resource "openstack_compute_servergroup_v2" "data_servers" {
  name     = "data_servers"
  policies = ["anti-affinity"]
}

resource "openstack_networking_secgroup_v2" "data_servers" {
  name                 = "data_servers"
  description          = "Data servers security group: ingress SSH and ICMP, egress to all addresses."
  delete_default_rules = true

  region = var.region
}

resource "openstack_networking_secgroup_rule_v2" "ingress_tcp_ipv4" {
  for_each = local.ingress_tcp_rules

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.data_servers.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.data_servers
  ]
}

resource "openstack_networking_secgroup_rule_v2" "ingress_udp_ipv4" {
  for_each = local.ingress_udp_rules

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "udp"
  port_range_min    = each.value.port
  port_range_max    = each.value.port
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.data_servers.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.data_servers
  ]
}

resource "openstack_networking_secgroup_rule_v2" "ingress_icmp_ipv4" {
  for_each = local.ingress_icmp_rules

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.data_servers.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.data_servers
  ]
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv4" {
  for_each = local.egress_rules

  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = each.value.cidr
  security_group_id = openstack_networking_secgroup_v2.data_servers.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.data_servers
  ]
}

resource "openstack_networking_port_v2" "data_server_port" {
  count = var.vm_count

  name           = format("%s-%02d-port", var.name_prefix, count.index + 1)
  network_id     = var.network_id
  admin_state_up = true
  region         = var.region

  security_group_ids = [
    openstack_networking_secgroup_v2.data_servers.id
  ]

  depends_on = [
    openstack_networking_secgroup_rule_v2.ingress_tcp_ipv4,
    openstack_networking_secgroup_rule_v2.ingress_udp_ipv4,
    openstack_networking_secgroup_rule_v2.ingress_icmp_ipv4,
    openstack_networking_secgroup_rule_v2.egress_ipv4
  ]
}

resource "openstack_compute_instance_v2" "data_server" {
  count = var.vm_count

  name              = format("%s-%02d", var.name_prefix, count.index + 1)
  image_name        = var.image_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  availability_zone = var.availability_zone
  metadata          = var.metadata
  user_data         = var.user_data
  config_drive      = var.config_drive
  region            = var.region

  scheduler_hints {
    group = openstack_compute_servergroup_v2.data_servers.id
  }

  network {
    port = openstack_networking_port_v2.data_server_port[count.index].id
  }

  depends_on = [
    openstack_compute_servergroup_v2.data_servers,
    openstack_networking_port_v2.data_server_port
  ]
}

resource "openstack_blockstorage_volume_v3" "data_volume" {
  count = var.volumes_enabled ? var.vm_count : 0

  name        = format("%s-%02d-data", var.name_prefix, count.index + 1)
  size        = var.data_volume_size
  description = "Data volume for data server"
  metadata    = var.data_volume_metadata
  region      = var.region
}

resource "openstack_compute_volume_attach_v2" "data_volume_attach" {
  count = var.volumes_enabled ? var.vm_count : 0

  instance_id = openstack_compute_instance_v2.data_server[count.index].id
  volume_id   = openstack_blockstorage_volume_v3.data_volume[count.index].id
  region      = var.region

  depends_on = [
    openstack_compute_instance_v2.data_server,
    openstack_blockstorage_volume_v3.data_volume
  ]
}

resource "openstack_networking_floatingip_v2" "data_server_fip" {
  count = var.attach_fip ? var.vm_count : 0

  pool   = "external"
  region = var.region
}

resource "openstack_networking_floatingip_associate_v2" "data_server_fip_assoc" {
  count = var.attach_fip ? var.vm_count : 0

  floating_ip = openstack_networking_floatingip_v2.data_server_fip[count.index].address
  port_id     = openstack_networking_port_v2.data_server_port[count.index].id
  region      = var.region

  depends_on = [
    openstack_compute_instance_v2.data_server,
    openstack_networking_floatingip_v2.data_server_fip
  ]
}

resource "openstack_lb_loadbalancer_v2" "data_servers" {
  name          = var.loadbalancer_name
  vip_subnet_id = var.lb_vip_subnet_id
  flavor_id     = var.loadbalancer_flavor_id
  region        = var.region

  depends_on = [
    openstack_compute_instance_v2.data_server
  ]
}

resource "openstack_lb_listener_v2" "data_servers" {
  name            = format("%s-listener", var.loadbalancer_name)
  protocol        = var.loadbalancer_listener_protocol
  protocol_port   = var.loadbalancer_listener_port
  loadbalancer_id = openstack_lb_loadbalancer_v2.data_servers.id
  region          = var.region

  depends_on = [
    openstack_lb_loadbalancer_v2.data_servers
  ]
}

resource "openstack_lb_pool_v2" "data_servers" {
  name        = format("%s-pool", var.loadbalancer_name)
  protocol    = var.loadbalancer_pool_protocol
  lb_method   = var.loadbalancer_lb_method
  listener_id = openstack_lb_listener_v2.data_servers.id
  region      = var.region

  depends_on = [
    openstack_lb_listener_v2.data_servers
  ]
}

resource "openstack_lb_member_v2" "data_servers" {
  count = var.vm_count

  pool_id       = openstack_lb_pool_v2.data_servers.id
  address       = openstack_networking_port_v2.data_server_port[count.index].all_fixed_ips[0]
  protocol_port = var.loadbalancer_member_port
  subnet_id     = var.lb_member_subnet_id
  region        = var.region

  depends_on = [
    openstack_lb_pool_v2.data_servers,
    openstack_networking_port_v2.data_server_port
  ]
}

resource "openstack_lb_monitor_v2" "data_servers" {
  pool_id        = openstack_lb_pool_v2.data_servers.id
  type           = var.loadbalancer_monitor_type
  delay          = var.loadbalancer_monitor_delay
  timeout        = var.loadbalancer_monitor_timeout
  max_retries    = var.loadbalancer_monitor_max_retries
  url_path       = var.loadbalancer_monitor_url_path
  expected_codes = var.loadbalancer_monitor_expected_codes
}

resource "openstack_networking_floatingip_v2" "loadbalancer_vip_fip" {
  count = var.attach_lb_vip_fip ? 1 : 0

  pool    = "external"
  port_id = openstack_lb_loadbalancer_v2.data_servers.vip_port_id
  region  = var.region

  depends_on = [
    openstack_lb_loadbalancer_v2.data_servers
  ]
}
