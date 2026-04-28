# Example invocations

## Minimal

```hcl
module "bastion" {
  source = "./modules/bastion"

  network_id  = "UUID-OF-TENANT-NETWORK" #optional
  image_name  = "ubuntu-24.04"
  flavor_name = "m1.small"
}
```

## Two virtual machines without floating IPs

```hcl
module "bastion" {
  source = "./modules/bastion"

  network_id  = "UUID-OF-TENANT-NETWORK" #optional
  image_name  = "ubuntu-24.04"
  flavor_name = "m1.small"
  key_pair    = "my-key"

  vm_count    = 2
  name_prefix = "app"
}
```

## Virtual machines with floating IPs from network external

```hcl
module "bastion" {
  source = "./modules/bastion"

  network_id  = "UUID-OF-TENANT-NETWORK" #optional
  image_name  = "ubuntu-24.04"
  flavor_name = "m1.small"
  key_pair    = "my-key"

  attach_fip = true
}
```

## Reading outputs

```bash
tofu output -json
tofu output -json floating_ips
```
