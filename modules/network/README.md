# network module

Creates one tenant network with one or more subnets (IPv4 and/or IPv6), one router with interfaces attached to all created subnets, and one `standard` security group.

## Features

- One `openstack_networking_network_v2` tenant network.
- One or more `openstack_networking_subnet_v2` subnets, depending on configuration.
- One `openstack_networking_router_v2` with interfaces attached to all created subnets.
- One `openstack_networking_secgroup_v2` named `standard`.
- Ingress rules allowing SSH and ICMP from any IPv4 address.
- Egress rule allowing traffic only to `10.0.0.0/24` over IPv4.

## Requirements

- OpenTofu or Terraform `>= 1.6.0`
- OpenStack provider `3.4.0`
- OpenStack cloud with Neutron networking API
- Existing external network ID for router gateway configuration

## Usage

```hcl
module "network" {
  source = "./modules/network"

  region              = null
  network_name        = "MY_TENANT_NETWORK_NAME"
  router_name         = "MY_TENANT_ROUTER_NAME"
  external_network_id = "UUID-OF-EXTERNAL-NETWORK"

  subnets = [
    {
      name       = "MY_TENANT_IPV4_SUBNET_NAME"
      cidr       = "192.168.10.0/24"
      ip_version = 4
      allocation_pools = [
        {
          start = "192.168.10.100"
          end   = "192.168.10.150"
        }
      ]
    }
  ]
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `null` | OpenStack region for all networking resources; inherits provider region when null. |
| `network_name` | `string` | n/a | Name of the tenant network to create. |
| `router_name` | `string` | `"router-1"` | Name of the router to create. |
| `external_network_id` | `string` | n/a | ID of the existing external network used as router gateway. |
| `subnets` | `list(object(...))` | n/a | List of subnets to create in the tenant network; supports IPv4 and IPv6. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `network` | No | Created tenant network: id, name and region. |
| `subnets` | No | List of created subnets with id, name, cidr and ip_version. |
| `router` | No | Created router with all attached subnet interfaces. |
| `standard_secgroup` | No | Created `standard` security group: id and name. |

## Security notes

- The `standard` security group allows inbound SSH and ICMP from any IPv4 address, so it should be used only where that exposure is acceptable.
- Egress is restricted to `10.0.0.0/24`; any other outbound IPv4 traffic remains blocked unless additional rules are added.
- If IPv6 security group behaviour is required, define dedicated IPv6 rules explicitly instead of assuming IPv4 rules cover dual-stack traffic.
