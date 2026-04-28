output "network" {
  description = "Created tenant network."
  value = {
    id     = openstack_networking_network_v2.tenant_net.id
    name   = openstack_networking_network_v2.tenant_net.name
    region = var.region
  }
}

output "subnets" {
  description = "List of created subnets."
  value = [
    for s in openstack_networking_subnet_v2.tenant_subnet : {
      id         = s.id
      name       = s.name
      cidr       = s.cidr
      ip_version = s.ip_version
    }
  ]
}

output "router" {
  description = "Created router with all attached subnet interfaces."
  value = {
    id   = openstack_networking_router_v2.router.id
    name = openstack_networking_router_v2.router.name
    interfaces = [
      for iface in openstack_networking_router_interface_v2.router_int : {
        id        = iface.id
        subnet_id = iface.subnet_id
        router_id = iface.router_id
      }
    ]
  }
}

output "standard_secgroup" {
  description = "Created standard security group."
  value = {
    id   = openstack_networking_secgroup_v2.standard.id
    name = openstack_networking_secgroup_v2.standard.name
  }
}
