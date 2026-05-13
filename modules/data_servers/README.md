# data_servers module

Creates one or more OpenStack virtual machines with dedicated data volumes, places them in a server group named `data_servers` with anti-affinity policy, optionally assigns floating IPs to the virtual machines, and places all virtual machines behind an Octavia load balancer. Optionally, the load balancer VIP can also receive a floating IP from the `external` network.

Ingress and egress rules for the dedicated security group can be customized via lists of CIDRs and TCP/UDP ports.

## Features

- Two `openstack_compute_instance_v2` virtual machines by default, configurable to any number.
- One `openstack_compute_servergroup_v2` named `data_servers` with `anti-affinity` policy.
- One dedicated security group for data servers with configurable ingress and egress rules.
- One Neutron port per virtual machine with the created security group attached.
- One dedicated data volume per virtual machine using `openstack_blockstorage_volume_v3` (optional, can be disabled).
- Optional floating IP allocation from network `external` for each virtual machine.
- One Octavia load balancer with configurable flavor.
- Optional floating IP allocation from network `external` for the load balancer VIP.

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
module "data_servers" {
  source = "./modules/data_servers"

  network_id          = "UUID-OF-TENANT-NETWORK"
  lb_vip_subnet_id    = "UUID-OF-TENANT-NETWORK-SUBNET"
  lb_member_subnet_id = "UUID-OF-TENANT-NETWORK-SUBNET"

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  key_pair            = "MY_KEY_NAME"

  vm_count            = 2
  data_volume_size    = 20
  volumes_enabled     = true

  # Security group rules
  allowed_ingress_cidrs     = ["10.10.0.0/16"]
  allowed_ingress_tcp_ports =[22,80]
  allowed_ingress_udp_ports = []
  allowed_egress_cidrs      = ["0.0.0.0/0"]

  loadbalancer_flavor_id = "UUID-OF-LB-FLAVOR"
  attach_fip             = true
  attach_lb_vip_fip      = true
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
| `volumes_enabled` | `bool` | `true` | Whether data volumes should be created and attached to the virtual machines. |
| `data_volume_size` | `number` | `20` | Size of the data volume per virtual machine, in GB. |
| `data_volume_metadata` | `map(string)` | `{}` | Optional metadata for all data volumes. |
| `attach_fip` | `bool` | `false` | Whether to allocate and associate a floating IP from network `external` for each virtual machine. |
| `allowed_ingress_cidrs` | `list(string)` | `["0.0.0.0/0"]` | List of IPv4 CIDR ranges allowed on ingress (used for TCP, UDP and ICMP rules). |
| `allowed_ingress_tcp_ports` | `list(number)` | `[22, 80]` | List of TCP ports allowed on ingress. |
| `allowed_ingress_udp_ports` | `list(number)` | `[]` | List of UDP ports allowed on ingress. An empty list means no UDP ingress rules are created. |
| `allowed_egress_cidrs` | `list(string)` | `["0.0.0.0/0"]` | List of IPv4 CIDR ranges allowed on egress. |
| `loadbalancer_name` | `string` | `"data-servers-lb"` | Load balancer name. |
| `loadbalancer_flavor_id` | `string` | n/a | Flavor ID of the Octavia load balancer. |
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

### Security group behavior

- For each CIDR in `allowed_ingress_cidrs` and each port in `allowed_ingress_tcp_ports`, a TCP ingress rule is created.
- For each CIDR in `allowed_ingress_cidrs` and each port in `allowed_ingress_udp_ports`, a UDP ingress rule is created (if the list is not empty).
- For each CIDR in `allowed_ingress_cidrs`, an ICMP ingress rule is created.
- For each CIDR in `allowed_egress_cidrs`, an IPv4 egress rule allowing all protocols to that CIDR is created.

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `server_group` | No | Created anti-affinity server group. |
| `security_group` | No | Created security group for data servers. |
| `ports` | No | Created Neutron ports. |
| `vms` | No | Created virtual machines. |
| `data_volumes` | No | Created data volumes. |
| `floating_ips` | No | Allocated and associated VM floating IPs. |
| `loadbalancer` | No | Created load balancer. |
| `loadbalancer_vip_fip` | No | Floating IP associated to the load balancer VIP, if enabled. |

## Security notes

- Ingress rules are controlled explicitly by `allowed_ingress_cidrs` and port lists for TCP/UDP.
- ICMP ingress rules are created for all CIDRs listed in `allowed_ingress_cidrs`.
- Egress rules are restricted to `allowed_egress_cidrs`.
- Floating IPs expose resources externally and should be enabled only when required.

