locals {
  user_data_path = "${path.root}/files/${var.name_prefix}-cloud-init.yml"
}

resource "openstack_networking_secgroup_v2" "bastion_ssh_icmp" {
  name                 = "bastion_ssh_icmp"
  description          = "Bastion security group: ingress configurable TCP ports and ICMP, egress to all addresses."
  delete_default_rules = true

  region = var.region
}

resource "openstack_networking_secgroup_rule_v2" "ingress_tcp_ipv4" {
  for_each = toset([for port in var.allowed_tcp_ports : tostring(port)])

  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = tonumber(each.key)
  port_range_max    = tonumber(each.key)
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.bastion_ssh_icmp
  ]
}

resource "openstack_networking_secgroup_rule_v2" "ingress_icmp_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.bastion_ssh_icmp
  ]
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv4_any" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.bastion_ssh_icmp
  ]
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv6_any" {
  direction         = "egress"
  ethertype         = "IPv6"
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.bastion_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.bastion_ssh_icmp
  ]
}

resource "openstack_networking_port_v2" "vm_port" {
  count = var.vm_count

  name           = format("%s-%02d-port", var.name_prefix, count.index + 1)
  network_id     = var.network_id
  admin_state_up = true
  region         = var.region

  security_group_ids = [
    openstack_networking_secgroup_v2.bastion_ssh_icmp.id
  ]

  depends_on = [
    openstack_networking_secgroup_rule_v2.ingress_tcp_ipv4,
    openstack_networking_secgroup_rule_v2.ingress_icmp_ipv4,
    openstack_networking_secgroup_rule_v2.egress_ipv4_any,
    openstack_networking_secgroup_rule_v2.egress_ipv6_any
  ]
}

resource "openstack_compute_instance_v2" "bastion" {
  count = var.vm_count

  name              = format("%s-%02d", var.name_prefix, count.index + 1)
  image_name        = var.image_name
  flavor_name       = var.flavor_name
  key_pair          = var.key_pair
  availability_zone = var.availability_zone
  metadata          = var.metadata
  user_data         = var.user_data != null ? var.user_data : (fileexists(local.user_data_path) ? file(local.user_data_path) : null)
  config_drive      = var.config_drive
  region            = var.region

  network {
    port = openstack_networking_port_v2.vm_port[count.index].id
  }

  depends_on = [
    openstack_networking_port_v2.vm_port
  ]
}

resource "openstack_networking_floatingip_v2" "bastion_fip" {
  count = var.attach_fip ? var.vm_count : 0

  pool   = "external"
  region = var.region
}

resource "openstack_networking_floatingip_associate_v2" "bastion_fip_assoc" {
  count = var.attach_fip ? var.vm_count : 0

  floating_ip = openstack_networking_floatingip_v2.bastion_fip[count.index].address
  port_id     = openstack_networking_port_v2.vm_port[count.index].id
  region      = var.region

  depends_on = [
    openstack_compute_instance_v2.bastion,
    openstack_networking_floatingip_v2.bastion_fip
  ]
}
