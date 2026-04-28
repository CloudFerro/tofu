# simple_vm module

Creates one or more OpenStack virtual machines attached to a specified tenant network, along with a dedicated security group named `simple_vm_ssh_icmp`. Optionally, each virtual machine can receive a floating IP allocated from the `external` network.

## Features

- One or more `openstack_compute_instance_v2` virtual machines.
- One dedicated `openstack_networking_secgroup_v2` named `simple_vm_ssh_icmp`.
- Ingress rules allowing SSH and ICMP from any IPv4 address.
- Egress rules allowing traffic to all IPv4 and IPv6 addresses.
- One Neutron port per virtual machine with the created security group attached.
- Optional floating IP allocation from the `external` network and association for each virtual machine.

## Requirements

- OpenTofu or Terraform `>= 1.6.0`
- OpenStack provider `3.4.0`
- OpenStack cloud with Nova and Neutron APIs
- Existing tenant network ID for port attachment
- Existing image and flavor
- Optional existing key pair

## Usage

```hcl
module "simple_vm" {
  source = "./modules/simple_vm"

  network_id  = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  image_name  = "MY_IMAGE_NAME"
  flavor_name = "MY_FLAVOR_NAME"
  key_pair    = "MY_KEY_NAME"

  vm_count    = 1
  name_prefix = "MY_VM_NAME"

  attach_fip  = true
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `null` | Region for all resources; inherits provider region when null. |
| `vm_count` | `number` | `1` | Number of virtual machines to create. |
| `name_prefix` | `string` | `"simple-vm"` | Prefix used to build VM and port names. |
| `network_id` | `string` | n/a | Tenant network ID where VM ports are created. |
| `image_name` | `string` | n/a | Image name used to boot instances. |
| `flavor_name` | `string` | n/a | Flavor name used by instances. |
| `key_pair` | `string` | `null` | Optional key pair name. |
| `availability_zone` | `string` | `null` | Optional availability zone. |
| `metadata` | `map(string)` | `{}` | Optional metadata for all instances. |
| `user_data` | `string` | `null` | Optional cloud-init or user-data content. |
| `config_drive` | `bool` | `false` | Whether to enable config drive. |
| `attach_fip` | `bool` | `false` | Whether to allocate and associate a floating IP from network `external` for each virtual machine. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `security_group` | No | Created `simple_vm_ssh_icmp` security group. |
| `ports` | No | Created Neutron ports. |
| `vms` | No | Created virtual machines. |
| `floating_ips` | No | Allocated and associated floating IPs, if enabled. |

## Security notes

- Ingress is intentionally limited to SSH and ICMP over IPv4 only.
- Egress is open to all IPv4 and IPv6 destinations.
- Floating IPs expose virtual machines externally and should be enabled only when required.
