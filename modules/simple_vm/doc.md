# Example invocations

## Minimal

```hcl
module "simple_vm" {
  source = "./modules/simple_vm"

  network_id  = "UUID-OF-TENANT-NETWORK" #optional
  image_name  = "MY_IMAGE_NAME"
  flavor_name = "MY_FLAVOR_NAME"
}
```

## Two virtual machines without floating IPs

```hcl
module "simple_vm" {
  source = "./modules/simple_vm"

  network_id  = "UUID-OF-TENANT-NETWORK" #optional
  image_name  = "MY_IMAGE_NAME"
  flavor_name = "MY_FLAVOR_NAME"
  key_pair    = "MY_KEY_NAME"

  vm_count    = 2
  name_prefix = "app"
}
```

## Virtual machines with floating IPs from network external

```hcl
module "simple_vm" {
  source = "./modules/simple_vm"

  network_id  = "UUID-OF-TENANT-NETWORK" #optional
  image_name  = "MY_IMAGE_NAME"
  flavor_name = "MY_FLAVOR_NAME"
  key_pair    = "MY_KEY_NAME"

  attach_fip = true
}
```
