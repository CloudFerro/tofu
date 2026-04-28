# Example invocations

## Minimal

```hcl
module "share" {
  source = "./modules/share"

  name             = "MY_SHARE_NAME"
  share_network_id = "UUID-OF-SHARE-NETWORK"
}
```

## Share with ACL rules

```hcl
module "share" {
  source = "./modules/share"

  name              = "MY_SHARE_NAME"
  share_network_id  = "UUID-OF-SHARE-NETWORK"
  allowed_instance_ips = [
    "10.10.10.11",
    "10.10.10.12"
  ]
  access_level      = "rw"
}
```

## Disabled share creation

```hcl
module "share" {
  source = "./modules/share"

  share_enabled     = false
  name              = "MY_SHARE_NAME"
  share_network_id  = "UUID-OF-SHARE-NETWORK"
}
```
