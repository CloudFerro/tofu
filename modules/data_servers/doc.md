# Example invocations

## Minimal

```hcl
module "data_servers" {
  source = "./modules/data_servers"

  network_id          = "UUID-OF-TENANT-NETWORK"
  lb_vip_subnet_id    = "UUID-OF-TENANT-NETWORK-SUBNET"
  lb_member_subnet_id = "UUID-OF-TENANT-NETWORK-SUBNET"

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  loadbalancer_flavor_id = "UUID-OF-LB-FLAVOR"
}
```

This creates:
- Two virtual machines (by default).
- A `data_servers` server group with anti-affinity policy.
- A security group allowing:
  - TCP 22 and 80 from `0.0.0.0/0`.
  - ICMP from `0.0.0.0/0`.
  - Egress to `0.0.0.0/0`.
- One data volume per VM (20 GB).
- A load balancer without floating IPs.

## Two virtual machines with custom ingress and no UDP

```hcl
module "data_servers" {
  source = "./modules/data_servers"

  network_id          = "UUID-OF-TENANT-NETWORK"
  lb_vip_subnet_id    = "UUID-OF-TENANT-NETWORK-SUBNET"
  lb_member_subnet_id = "UUID-OF-TENANT-NETWORK-SUBNET"

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  key_pair            = "MY_KEY_NAME"

  vm_count            = 2
  data_volume_size    = 50
  volumes_enabled     = true

  allowed_ingress_cidrs     = ["10.10.0.0/16", "192.168.100.0/24"]
  allowed_ingress_tcp_ports =[22,443]
  allowed_ingress_udp_ports = []
  allowed_egress_cidrs      = ["0.0.0.0/0"]

  loadbalancer_flavor_id = "UUID-OF-LB-FLAVOR"
}
```

This creates:
- TCP ingress rules for ports 22 and 443 from both `10.10.0.0/16` and `192.168.100.0/24`.
- ICMP ingress from the same CIDRs.
- No UDP ingress (empty list).
- Egress to `0.0.0.0/0`.

## Virtual machines and load balancer with floating IPs and UDP allowed

```hcl
module "data_servers" {
  source = "./modules/data_servers"

  network_id          = "UUID-OF-TENANT-NETWORK"
  lb_vip_subnet_id    = "UUID-OF-TENANT-NETWORK-SUBNET"
  lb_member_subnet_id = "UUID-OF-TENANT-NETWORK-SUBNET"

  image_name          = "MY_IMAGE_NAME"
  flavor_name         = "MY_FLAVOR_NAME"
  key_pair            = "MY_KEY_NAME"

  vm_count        = 3
  volumes_enabled = false

  allowed_ingress_cidrs     = ["203.0.113.0/24"]
  allowed_ingress_tcp_ports =[22,80]
  allowed_ingress_udp_ports =[1194]
  allowed_egress_cidrs      = ["0.0.0.0/0"]

  loadbalancer_flavor_id = "UUID-OF-LB-FLAVOR"
  attach_fip             = true
  attach_lb_vip_fip      = true
}
```

This creates:
- TCP ingress: 22 and 80 from `203.0.113.0/24`.
- UDP ingress: 1194 from `203.0.113.0/24`.
- ICMP ingress from `203.0.113.0/24`.
- Egress to `0.0.0.0/0`.
- No data volumes (volumes disabled).
- Floating IP for each VM and for the load balancer VIP.


