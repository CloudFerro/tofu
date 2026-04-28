# Example invocations

## Minimal — current project scope

```hcl
module "bucket" {
  source = "./modules/bucket"

  bucket = {
    name = "logs-bucket"
  }
}
```

## Custom credential count with metadata and quotas

```hcl
module "bucket" {
  source = "./modules/bucket"

  bucket = {
    name          = "artifacts-bucket"
    metadata      = {
      environment = "prod"
      owner       = "platform-team"
    }
    force_destroy = false
  }

  ec2_credential_count = 2
}
```

## Admin-scoped credentials for a specific project

```hcl
module "bucket" {
  source = "./modules/bucket"

  bucket = {
    name = "backup-bucket"
  }

  ec2_credential_count      = 4
  ec2_credential_project_id = "f7ac731cc11f40efbc03a9f9e1d1d21f"
  ec2_credential_user_id    = "d8e2e9c6a0b54d38b3a1f2e4c5d6b7a8"
}
```

## Example commands

```bash
tofu init
tofu plan
tofu apply
```
