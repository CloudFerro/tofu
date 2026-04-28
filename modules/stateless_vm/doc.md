# Example invocations

## Minimal — single VM, no FIP

```hcl
module "stateless_vm" {
  source = "./modules/stateless_vm"

  name_prefix       = "MY_VM_NAME_PREFIX"
  image_name        = "MY_IMAGE_NAME"
  flavor_name       = "MY_FLAVOR_NAME"
  network_id        = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  security_group_id = "UUID-OF-SECURITY-GROUP"
  client_project    = "MY_BUSINESS_PROJECT_NAME"
}
```

```bash
export TF_VAR_stateless_vm_created_by=$OS_USERNAME
tofu apply
```

## Three VMs with floating IPs and cloud-init

Place `files/web-vm-cloud-init.yml` in the root module directory, then:

```hcl
module "stateless_vm" {
  source = "./modules/stateless_vm"

  name_prefix               = "MY_VM_NAME_PREFIX"
  vm_count                  = 3
  image_name                = "MY_IMAGE_NAME"
  flavor_name               = "MY_FLAVOR_NAME"
  network_id                = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  security_group_id         = "UUID-OF-SECURITY-GROUP"
  client_project            = "MY_BUSINESS_PROJECT_NAME"
  attach_fip                = true
  fip_floating_network_name = "external"
}
```

## Resize workflow — from MY_FLAVOR_NAME to m1.medium

```hcl
module "stateless_vm" {
  source = "./modules/stateless_vm"

  name_prefix       = "MY_VM_NAME_PREFIX"
  image_name        = "MY_IMAGE_NAME"
  flavor_name       = "MY_FLAVOR_NAME"
  network_id        = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  security_group_id = "UUID-OF-SECURITY-GROUP"
  client_project    = "MY_BUSINESS_PROJECT_NAME"
}
```

`vm_version` in metadata updates automatically — no manual counter needed.

## With additional custom metadata

```hcl
module "stateless_vm" {
  source = "./modules/stateless_vm"

  name_prefix       = "MY_VM_NAME_PREFIX"
  image_name        = "MY_IMAGE_NAME"
  flavor_name       = "MY_FLVOR_NAME"
  network_id        = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  security_group_id = "UUID-OF-SECURITY-GROUP"
  client_project    = "MY_BUSINESS_PROJECT_NAME"

  extra_metadata = {
    environment = "production"
    cost_center = "CC-1234"
    tier        = "database"
  }
}
```
