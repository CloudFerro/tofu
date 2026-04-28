module "network" {
  source = "./modules/network"

  region             = var.network_region
  network_name       = var.network_name
  router_name        = var.router_name
  external_network_id = var.external_network_id

  subnets = var.subnets
}
