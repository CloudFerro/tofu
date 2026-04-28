output "server_group" {
  description = "Created anti-affinity server group."
  value = {
    id       = openstack_compute_servergroup_v2.data_servers.id
    name     = openstack_compute_servergroup_v2.data_servers.name
    policies = openstack_compute_servergroup_v2.data_servers.policies
  }
}

output "security_group" {
  description = "Created security group for data servers."
  value = {
    id   = openstack_networking_secgroup_v2.data_servers.id
    name = openstack_networking_secgroup_v2.data_servers.name
  }
}

output "ports" {
  description = "Created Neutron ports."
  value = [
    for port in openstack_networking_port_v2.data_server_port : {
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
    for vm in openstack_compute_instance_v2.data_server : {
      id   = vm.id
      name = vm.name
    }
  ]
}

output "data_volumes" {
  description = "Created data volumes."
  value = [
    for volume in openstack_blockstorage_volume_v3.data_volume : {
      id   = volume.id
      name = volume.name
      size = volume.size
    }
  ]
}

output "data_volume_attachments" {
  description = "Created data volume attachments."
  value = [
    for attach in openstack_compute_volume_attach_v2.data_volume_attach : {
      id          = attach.id
      instance_id = attach.instance_id
      volume_id   = attach.volume_id
      device      = attach.device
    }
  ]
}

output "floating_ips" {
  description = "Allocated and associated floating IPs for virtual machines."
  value = var.attach_fip ? [
    for i in range(var.vm_count) : {
      instance_id = openstack_compute_instance_v2.data_server[i].id
      instance    = openstack_compute_instance_v2.data_server[i].name
      address     = openstack_networking_floatingip_v2.data_server_fip[i].address
      port_id     = openstack_networking_port_v2.data_server_port[i].id
    }
  ] : []
}

output "loadbalancer" {
  description = "Created load balancer."
  value = {
    id          = openstack_lb_loadbalancer_v2.data_servers.id
    name        = openstack_lb_loadbalancer_v2.data_servers.name
    vip_address = openstack_lb_loadbalancer_v2.data_servers.vip_address
    vip_port_id = openstack_lb_loadbalancer_v2.data_servers.vip_port_id
  }
}

output "loadbalancer_vip_fip" {
  description = "Floating IP associated to the load balancer VIP."
  value = var.attach_lb_vip_fip ? {
    address = openstack_networking_floatingip_v2.loadbalancer_vip_fip[0].address
    port_id = openstack_networking_floatingip_v2.loadbalancer_vip_fip[0].port_id
  } : null
}
