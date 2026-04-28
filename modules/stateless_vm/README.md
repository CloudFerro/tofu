# stateless_vm module

Creates one or more OpenStack virtual machines designed for stateless workloads with automatic flavor change tracking, structured classification metadata, and safe rebuild lifecycle. Does not create security groups — the security group UUID must be provided by the caller.

## Features

- One or more `openstack_compute_instance_v2` instances named `<name_prefix>-NN`.
- Structured metadata for cost classification: creator, business project, additional key=value metadata
- No security group creation,— caller provides security group UUID.
- Optional user-data loaded automatically from `files/<name_prefix>-cloud-init.yml` or from stateless_vm.auto.tfvars
- Optional floating IP per VM.
- Minimal state footprint — dynamic OpenStack fields excluded from diff via `ignore_changes`.

## Requirements

- OpenTofu `>= 1.6.0`
- OpenStack provider `3.4.0`
- Existing network UUID
- Existing security group UUID

## Usage

```hcl
module "stateless_vm" {
  source = "./modules/stateless_vm"

  name_prefix       = "MY_VM_NAME_PREFIX"
  image_name        = "MY_IMAGE_NAME"
  flavor_name       = "MY_FLAVOR_NAME"
  network_id        = module.network.network.id
  security_group_id = "UUID-OF-SECURITY-GROUP"
  client_project    = "MY_BUSINESS_PROJECT_NAME"
}
```

```bash
export TF_VAR_stateless_vm_created_by=$OS_USERNAME
tofu apply
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `null` | OpenStack region; inherits provider region when null. |
| `vm_count` | `number` | `1` | Number of VMs to create. |
| `name_prefix` | `string` | n/a | VM name prefix; each VM is named `<prefix>-NN`. |
| `image_name` | `string` | n/a | Image name. |
| `flavor_name` | `string` | n/a | Flavor name. |
| `key_pair` | `string` | `null` | Optional SSH key pair. |
| `network_id` | `string` | n/a | Tenant network UUID. |
| `security_group_id` | `string` | n/a | Security group UUID. Module does not create SGs. |
| `availability_zone` | `string` | `null` | Optional availability zone. |
| `config_drive` | `bool` | `false` | Whether to enable config drive. |
| `created_by` | `string` | `"unknown"` | VM creator. Set via `TF_VAR_stateless_vm_created_by=$OS_USERNAME`. |
| `client_project` | `string` | n/a | Business project for cost classification. |
| `extra_metadata` | `map(string)` | `{}` | Additional metadata merged with classification metadata. |
| `attach_fip` | `bool` | `false` | Whether to allocate and associate a floating IP per VM. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `vms` | No | Created VMs with id, name, flavor, network. |
| `floating_ips` | No | Allocated floating IPs, if enabled. |

## Metadata applied to VMs

| Key | Source | Description |
|---|---|---|
| `created_by` | `var.created_by` | Creator username. Set via `TF_VAR_stateless_vm_created_by=$OS_USERNAME`. |
| `client_project` | `var.client_project` | Business project for cost classification. |
| `managed_by` | static | Always `opentofu`. |

## Resize workflow

1. Change `flavor_name` to the new flavor.
2. Run `tofu apply`.

## User-data

If `files/<name_prefix>-cloud-init.yml` exists in the root module directory it is automatically used as user-data. Changing this file triggers a VM rebuild on next `tofu apply`.

## State and ignore_changes

`user_data` is intentionally **not** ignored,—a file change triggers rebuild.

## Security notes

- No security groups are created by this module.
- `created_by` must not be stored in version-controlled `.tfvars`. Use `TF_VAR_stateless_vm_created_by` env variable.

