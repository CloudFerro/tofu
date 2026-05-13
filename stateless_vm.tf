module "stateless_vm" {
  source = "./modules/stateless_vm"

  region            = var.stateless_vm_region
  vm_count          = var.stateless_vm_count
  name_prefix       = var.stateless_vm_name_prefix
  network_id        = var.stateless_vm_network_id
  image_name        = var.stateless_vm_image_name
  flavor_name       = var.stateless_vm_flavor_name
  key_pair          = var.stateless_vm_key_pair
  availability_zone = var.stateless_vm_availability_zone
  config_drive      = var.stateless_vm_config_drive
  security_group_id = var.stateless_vm_security_group_id
  attach_fip        = var.stateless_vm_attach_fip

  created_by      = var.stateless_vm_created_by
  client_project  = var.stateless_vm_client_project
  extra_metadata  = var.stateless_vm_extra_metadata
}


