# bucket module

Creates one OpenStack Object Storage container and a configurable number of EC2 credential pairs (access key + secret key) suitable for S3-compatible Swift/RadosGW endpoints.

## Features

- One `openstack_objectstorage_container_v1` resource.
- Four `openstack_identity_ec2_credential_v3` resources by default (configurable).
- All bucket arguments exposed as optional object attributes.
- EC2 credential outputs marked as `sensitive`.

## Requirements

- OpenTofu or Terraform `>= 1.6.0`
- OpenStack provider `3.4.0`
- OpenStack cloud with Object Storage and Identity APIs

## Usage

```hcl
module "bucket" {
  source = "./modules/bucket"

  bucket = {
    name = "example-bucket"
  }

  ec2_credential_count = 4
}
```

## Inputs

| Name | Type | Default | Description |
|---|---|---|---|
| `bucket` | `object(...)` | n/a | Bucket configuration. `name` is required; all other attributes are optional. |
| `ec2_credential_count` | `number` | `4` | Number of EC2 credential pairs to create. |
| `ec2_credential_project_id` | `string` | `null` | Optional project scope for the credentials (admin only for non-current project). |
| `ec2_credential_user_id` | `string` | `null` | Optional user ID for the credentials (admin only for non-current user). |
| `ec2_credential_region` | `string` | `null` | Region for EC2 credentials; inherits provider region when null. |

## Outputs

| Name | Sensitive | Description |
|---|---|---|
| `bucket` | No | Container id, name and region. |
| `ec2_credentials` | **Yes** | List of `{access, secret, user_id, project_id}` objects. |

## Security notes

- Keep `*.auto.tfvars` containing secrets out of version control (add to `.gitignore`).
- Pass provider secrets via environment variables (`OS_PASSWORD`, `OS_USERNAME`, etc.) in CI/CD.
- `ec2_credentials` output is sensitive but secrets still persist in local state — protect the state file.
