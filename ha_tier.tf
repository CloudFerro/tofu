module "ha_tier" {
  source = "./modules/ha_tier"

  region            = var.ha_tier_region
  vm_count          = var.ha_tier_count
  name_prefix       = var.ha_tier_name_prefix
  network_id        = coalesce(var.ha_tier_network_id, module.network.network.id)
  image_name        = var.ha_tier_image_name
  flavor_name       = var.ha_tier_flavor_name
  key_pair          = var.ha_tier_key_pair
  availability_zone = var.ha_tier_availability_zone
  metadata          = var.ha_tier_metadata
  user_data         = var.ha_tier_user_data
  config_drive      = var.ha_tier_config_drive

  attach_fip           = var.ha_tier_attach_fip

  allowed_ingress_cidrs     = var.ha_tier_allowed_ingress_cidrs
  allowed_ingress_tcp_ports = var.ha_tier_allowed_ingress_tcp_ports
  allowed_ingress_udp_ports = var.ha_tier_allowed_ingress_udp_ports
  allowed_egress_cidrs      = var.ha_tier_allowed_egress_cidrs

  loadbalancer_name                   = var.ha_tier_loadbalancer_name
  loadbalancer_flavor_id              = var.ha_tier_loadbalancer_flavor_id
  lb_vip_subnet_id                    = coalesce(var.ha_tier_lb_vip_subnet_id, module.network.subnets[0].id)
  lb_member_subnet_id                 = coalesce(var.ha_tier_lb_member_subnet_id, module.network.subnets[0].id)
  loadbalancer_listener_protocol      = var.ha_tier_lb_listener_protocol
  loadbalancer_listener_port          = var.ha_tier_lb_listener_port
  loadbalancer_pool_protocol          = var.ha_tier_lb_pool_protocol
  loadbalancer_lb_method              = var.ha_tier_lb_method
  loadbalancer_member_port            = var.ha_tier_lb_member_port
  loadbalancer_monitor_type           = var.ha_tier_lb_monitor_type
  loadbalancer_monitor_delay          = var.ha_tier_lb_monitor_delay
  loadbalancer_monitor_timeout        = var.ha_tier_lb_monitor_timeout
  loadbalancer_monitor_max_retries    = var.ha_tier_lb_monitor_max_retries
  loadbalancer_monitor_url_path       = var.ha_tier_lb_monitor_url_path
  loadbalancer_monitor_expected_codes = var.ha_tier_lb_monitor_expected_codes
  attach_lb_vip_fip                   = var.ha_tier_attach_lb_vip_fip
}
