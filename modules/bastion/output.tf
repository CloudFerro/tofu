output "security_group" {
  description = "Created security group for bastion virtual machines."
  value = {
    id   = openstack_networking_secgroup_v2.bastion_ssh_icmp.id
    name = openstack_networking_secgroup_v2.bastion_ssh_icmp.name
  }
}

output "ports" {
  description = "Created Neutron ports."
  value = [
    for port in openstack_networking_port_v2.vm_port : {
      id         = port.id
      name       = port.name
      network_id = port.network_id
      mac        = port.mac_address
      fixed_ips  = port.all_fixed_ips
    }
  ]
}

output "vms" {
  description = "Created virtual machines."
  value = [
    for vm in openstack_compute_instance_v2.bastion : {
      id   = vm.id
      name = vm.name
    }
  ]
}

output "floating_ips" {
  description = "Allocated and associated floating IPs."
  value = var.attach_fip ? [
    for i in range(var.vm_count) : {
      instance_id = openstack_compute_instance_v2.bastion[i].id
      instance    = openstack_compute_instance_v2.bastion[i].name
      address     = openstack_networking_floatingip_v2.bastion_fip[i].address
      port_id     = openstack_networking_port_v2.vm_port[i].id
    }
  ] : []
}
