module "simple_vm" {
  source = "./modules/simple_vm"

  region            = var.simple_vm_region
  vm_count          = var.simple_vm_count
  name_prefix       = var.simple_vm_name_prefix
  network_id        = coalesce(var.simple_vm_network_id, module.network.network.id)
  image_name        = var.simple_vm_image_name
  flavor_name       = var.simple_vm_flavor_name
  key_pair          = var.simple_vm_key_pair
  availability_zone = var.simple_vm_availability_zone
  metadata          = var.simple_vm_metadata
  user_data         = var.simple_vm_user_data
  config_drive      = var.simple_vm_config_drive
  attach_fip        = var.simple_vm_attach_fip
}
