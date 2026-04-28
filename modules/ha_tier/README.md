# ha_tier module

Creates one or more OpenStack virtual machines and, places them in a server group named `ha_tier` with soft-anti-affinity policy, optionally assigns floating IPs to the virtual machines, and places all virtual machines behind an Octavia load balancer. Optionally, the load balancer VIP can also receive a floating IP from the `external` network.

## Features

- Two `openstack_compute_instance_v2` virtual machines by default, configurable to any number.
- One `openstack_compute_servergroup_v2` named `ha_tier` with `soft-anti-affinity` policy.
- One dedicated data volume per virtual machine using `openstack_blockstorage_volume_v3`.
- Optional floating IP allocation from network `external` for each virtual machine.
- One Octavia load balancer with configurable flavor.
- Optional floating IP allocation from network `external` for the load balancer VIP.
- One dedicated security group for the virtual machines.

## Requirements

- OpenTofu or Terraform `>= 1.6.0`
- OpenStack provider `3.4.0`
- OpenStack cloud with Nova, Neutron, Cinder and Octavia APIs
- Existing tenant network ID for VM attachment
- Existing subnet ID for load balancer VIP and members
- Existing image and flavor for virtual machines
- Load balancer flavor available in the target cloud

## Usage

```hcl
module "ha_tier" {
  source = "./modules/ha_tier"

  network_id          = coalesce(var.ha_tier_network_id, module.network.network.id)
  lb_vip_subnet_id    = module.network.subnets.id
  lb_member_subnet_id = module.network.subnets.id

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  key_pair            = "MY_KEY_NAME"

  vm_count            = 2

  loadbalancer_flavor = "small"
  attach_fip          = true
  attach_lb_vip_fip   = true
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `null` | Region for all resources; inherits provider region when null. |
| `vm_count` | `number` | `2` | Number of virtual machines to create. |
| `name_prefix` | `string` | `"data-server"` | Prefix used to build VM, port and volume names. |
| `network_id` | `string` | n/a | Tenant network ID where VM ports are created. |
| `image_name` | `string` | n/a | Image name used to boot instances. |
| `flavor_name` | `string` | n/a | Flavor name used by instances. |
| `key_pair` | `string` | `null` | Optional key pair name. |
| `availability_zone` | `string` | `null` | Optional availability zone. |
| `metadata` | `map(string)` | `{}` | Optional metadata for all instances. |
| `user_data` | `string` | `null` | Optional cloud-init or user-data content. |
| `config_drive` | `bool` | `false` | Whether to enable config drive. |
| `attach_fip` | `bool` | `false` | Whether to allocate and associate a floating IP from network `external` for each virtual machine. |
| `loadbalancer_name` | `string` | `"data-servers-lb"` | Load balancer name. |
| `loadbalancer_flavor` | `string` | n/a | Flavor of the Octavia load balancer. |
| `lb_vip_subnet_id` | `string` | n/a | Subnet ID used by the load balancer VIP. |
| `lb_member_subnet_id` | `string` | n/a | Subnet ID used for load balancer members. |
| `loadbalancer_listener_protocol` | `string` | `"TCP"` | Listener protocol. |
| `loadbalancer_listener_port` | `number` | `80` | Listener port. |
| `loadbalancer_pool_protocol` | `string` | `"TCP"` | Pool protocol. |
| `loadbalancer_lb_method` | `string` | `"ROUND_ROBIN"` | Load balancing method. |
| `loadbalancer_member_port` | `number` | `80` | Backend member port. |
| `loadbalancer_monitor_type` | `string` | `"TCP"` | Health monitor type. |
| `loadbalancer_monitor_delay` | `number` | `10` | Health monitor delay. |
| `loadbalancer_monitor_timeout` | `number` | `5` | Health monitor timeout. |
| `loadbalancer_monitor_max_retries` | `number` | `3` | Health monitor max retries. |
| `loadbalancer_monitor_url_path` | `string` | `null` | Optional URL path for HTTP/HTTPS monitors. |
| `loadbalancer_monitor_expected_codes` | `string` | `null` | Optional expected HTTP response codes for HTTP/HTTPS monitors. |
| `attach_lb_vip_fip` | `bool` | `false` | Whether to associate a floating IP from network `external` to the load balancer VIP. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `server_group` | No | Created soft-anti-affinity server group. |
| `security_group` | No | Created security group for data servers. |
| `ports` | No | Created Neutron ports. |
| `vms` | No | Created virtual machines. |
| `floating_ips` | No | Allocated and associated VM floating IPs. |
| `loadbalancer` | No | Created load balancer. |
| `loadbalancer_vip_fip` | No | Floating IP associated to the load balancer VIP, if enabled. |

## Security notes

- Ingress is intentionally limited to SSH and ICMP over IPv4 only.
- Egress is open to all IPv4 and IPv6 destinations.
- Floating IPs expose resources externally and should be enabled only when required.
