module "share" {
  source = "./modules/share"

  region               = var.share_region
  share_enabled        = var.share_enabled
  name                 = var.share_name
  description          = var.share_description
  share_proto          = var.share_proto
  size                 = var.share_size
  share_network_id     = var.share_network_id
  availability_zone    = var.share_availability_zone
  metadata             = var.share_metadata
  allowed_instance_ips = var.share_allowed_instance_ips
  access_level         = var.share_access_level
  generate_mount_script = var.share_generate_mount_script
}

