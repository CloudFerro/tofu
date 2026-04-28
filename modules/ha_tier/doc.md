# Example invocations

## Minimal

```hcl
module "ha_tier" {
  source = "./modules/ha_tier"

  network_id          = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  lb_vip_subnet_id    = module.network.subnets.id
  lb_member_subnet_id = module.network.subnets.id

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  loadbalancer_flavor = "MY_LOADBALANCER_FLAVOR_NAME"
}
```

## Two virtual machines with no floating IPs

```hcl
module "ha_tier" {
  source = "./modules/ha_tier"

  network_id          = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  lb_vip_subnet_id    = module.network.subnets.id
  lb_member_subnet_id = module.network.subnets.id

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  key_pair            = "MY_KEY_NAME"

  vm_count            = 2
  loadbalancer_flavor = "MY_LOADBALANCER_FLAVOR_NAME"
}
```

## Virtual machines and load balancer with floating IPs from network external

```hcl
module "ha_tier" {
  source = "./modules/ha_tier"

  network_id          = "UUID-OF-TENANT-NETWORK" #in case if you want explicitly assign vm to some network. Not needed if network module is used before and tenant network is created
  lb_vip_subnet_id    = module.network.subnets.id
  lb_member_subnet_id = module.network.subnets.id

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  key_pair            = "MY_KEY_NAME"

  attach_fip          = true
  attach_lb_vip_fip   = true
  loadbalancer_flavor = "MY_LOADBALANCER_FLAVOR_NAME"
}
```
