resource "openstack_networking_secgroup_v2" "simple_vm_ssh_icmp" {
  name                 = "simple_vm_ssh_icmp"
  description          = "Simple VM security group: ingress SSH and ICMP, egress to all addresses."
  delete_default_rules = true

  region = var.region
}

resource "openstack_networking_secgroup_rule_v2" "ingress_ssh_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.simple_vm_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.simple_vm_ssh_icmp
  ]
}

resource "openstack_networking_secgroup_rule_v2" "ingress_icmp_ipv4" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "icmp"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.simple_vm_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.simple_vm_ssh_icmp
  ]
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv4_any" {
  direction         = "egress"
  ethertype         = "IPv4"
  remote_ip_prefix  = "0.0.0.0/0"
  security_group_id = openstack_networking_secgroup_v2.simple_vm_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.simple_vm_ssh_icmp
  ]
}

resource "openstack_networking_secgroup_rule_v2" "egress_ipv6_any" {
  direction         = "egress"
  ethertype         = "IPv6"
  remote_ip_prefix  = "::/0"
  security_group_id = openstack_networking_secgroup_v2.simple_vm_ssh_icmp.id
  region            = var.region

  depends_on = [
    openstack_networking_secgroup_v2.simple_vm_ssh_icmp
  ]
}

resource "openstack_networking_port_v2" "vm_port" {
  count = var.vm_count

  name           = format("%s-%02d-port", var.name_prefix, count.index + 1)
  network_id     = var.network_id
  admin_state_up = true
  region         = var.region

  security_group_ids = [
    openstack_networking_secgroup_v2.simple_vm_ssh_icmp.id
  ]

  depends_on = [
    openstack_networking_secgroup_rule_v2.ingress_ssh_ipv4,
    openstack_networking_secgroup_rule_v2.ingress_icmp_ipv4,
    openstack_networking_secgroup_rule_v2.egress_ipv4_any,
    openstack_networking_secgroup_rule_v2.egress_ipv6_any
  ]
}

resource "openstack_compute_instance_v2" "simple_vm" {
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

  network {
    port = openstack_networking_port_v2.vm_port[count.index].id
  }

  depends_on = [
    openstack_networking_port_v2.vm_port
  ]
}

resource "openstack_networking_floatingip_v2" "simple_vm_fip" {
  count = var.attach_fip ? var.vm_count : 0

  pool   = "external"
  region = var.region
}

resource "openstack_networking_floatingip_associate_v2" "simple_vm_fip_assoc" {
  count = var.attach_fip ? var.vm_count : 0

  floating_ip = openstack_networking_floatingip_v2.simple_vm_fip[count.index].address
  port_id     = openstack_networking_port_v2.vm_port[count.index].id
  region      = var.region

  depends_on = [
    openstack_compute_instance_v2.simple_vm,
    openstack_networking_floatingip_v2.simple_vm_fip
  ]
}
