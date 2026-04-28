# Example invocations

## Minimal IPv4 setup

```hcl
module "network" {
  source = "./modules/network"

  region             = null          # inherit from provider
  network_name       = "MY_TENANT_NETWORK_NAME"
  router_name        = "MY_TENANT_ROUTER_NAME"
  external_network_id = "UUID-OF-EXTERNAL-NETWORK"

  subnets = [
    {
      name       = "MY_TENANT_IPV4_SUBNET_NAME"
      cidr       = "192.168.10.0/24"
      ip_version = 4
    }
  ]
}
```

## Dual-stack: IPv4 + IPv6

```hcl
module "network" {
  source = "./modules/network"

  network_name        = "MY_TENANT_NETWORK_NAME"
  router_name         = "MY_TENANT_ROUTER_NAME"
  external_network_id = "UUID-OF-EXTERNAL-NETWORK"

  subnets = [
    {
      name       = "MY_TENANT_IPV4_SUBNET_NAME"
      cidr       = "192.168.20.0/24"
      ip_version = 4
    },
    {
      name              = "MY_TENANT_IPV6_SUBNET_NAME"
      cidr              = "2001:db8:1234:20::/64"
      ip_version        = 6
      ipv6_address_mode = "dhcpv6-stateless"
      ipv6_ra_mode      = "dhcpv6-stateless"
    }
  ]
}
```

## Using the standard security group

```hcl
resource "openstack_networking_port_v2" "vm_port" {
  name       = "MY_TENANT_VM_PORT_NAME"
  network_id = module.network.network.id

  security_group_ids = [
    module.network.standard_secgroup_id,
  ]
}
```
