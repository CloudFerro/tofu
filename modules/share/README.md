# share module

Creates a non-public OpenStack Manila share using an existing share network, optionally assigns IP-based ACL rules for selected instances, and can generate a local bash script used to mount the created share inside a virtual machine.

## Features

- One non-public `openstack_sharedfilesystem_share_v2` share.
- Existing share network passed by ID.
- IP-based ACL rules using `openstack_sharedfilesystem_share_access_v2`.
- Optional enable/disable flag for conditional creation.
- Access rules generated from a list of instance IP addresses.
- Optional generation of a local mount script in the root `files/` directory.
- Generated script uses absolute paths and `sudo` for operations that require elevated privileges.
- Generated script is idempotent and safe to run multiple times.

## Requirements

- OpenTofu or Terraform `>= 1.6.0`
- OpenStack provider `3.4.0`
- Null provider for local script generation
- OpenStack cloud with Manila API enabled
- Existing Manila share network
- Valid instance IP addresses for ACL rules
- A Linux virtual machine with NFS client support and sudo access for the user running the generated script

## Usage

```hcl
module "share" {
  source = "./modules/share"

  name = "MY_SHARE_NAME"
  share_network_id = "UUID-OF-SHARE-NETWORK"

  allowed_instance_ips = [
    "10.10.10.11",
    "10.10.10.12"
  ]

  generate_mount_script = true
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `region` | `string` | `null` | Region for all resources; inherits provider region when null. |
| `share_enabled` | `bool` | `true` | Whether the Manila share should be created. |
| `name` | `string` | n/a | Manila share name. |
| `description` | `string` | `null` | Optional share description. |
| `share_proto` | `string` | `"NFS"` | Share protocol. |
| `size` | `number` | `20` | Share size in GB. |
| `share_type` | `string` | `20` | Share type. |
| `share_network_id` | `string` | `null` | Existing share network ID. |
| `availability_zone` | `string` | `null` | Optional availability zone. |
| `metadata` | `map(string)` | `{}` | Optional share metadata. |
| `allowed_instance_ips` | `list(string)` | `[]` | Instance IP addresses allowed in the ACL. |
| `access_level` | `string` | `"rw"` | ACL access level, `rw` or `ro`. |
| `generate_mount_script` | `bool` | `true` | Whether a local mount script should be generated in the root `files/` directory. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `share` | No | Created Manila share. |
| `share_access_rules` | No | Created ACL rules. |
| `mount_script` | No | Generated local mount script path and target mount directory. |

## Generated mount script

When `generate_mount_script = true`, the module generates a bash script in the root module directory under:

```text
files/mount_<normalized_share_name>_share.sh
```

The normalized share name contains only lowercase letters, digits, and underscores.

The generated script:

- Uses absolute binary paths such as `/bin/mkdir`, `/bin/findmnt`, `/bin/mount`, and `/usr/bin/tee`.
- Uses `sudo` for operations requiring elevated privileges, so it can be run by any user with sudo access.
- Creates a target directory under `/mnt/<normalized_share_name>`.
- Checks whether the share is already mounted and prints:
  - `This share is already mounted in XXXX`
- Checks whether another share already has an `/etc/fstab` entry for the same target mount path and, if so, prints:
  - `Another share has entry for this mount path in /etc/fstab !`
  - then exits with an error.
- Checks whether the expected `/etc/fstab` entry already exists for the current share and adds it only when missing.
- Mounts the share and prints:
  - `Share mounted in XXXX`
- Prints the following message when the mount cannot be completed:
  - `Mount error, check if share is accesible and apropriate share access list exists`

## Idempotency

The generated mount script is designed to be idempotent:

- It does not duplicate the correct `/etc/fstab` entry.
- It does not remount a share that is already mounted.
- It stops safely if another share is already configured for the same mount path in `/etc/fstab`.
- It can be executed repeatedly without breaking an already correct mount configuration.

## Security notes

- The created share is always non-public.
- ACL rules are limited to explicitly listed IP addresses.
- Share network must already exist before module execution.
- Mount success depends on correct network reachability and a matching Manila access rule for the client IP.

