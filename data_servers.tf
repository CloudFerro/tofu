module "data_servers" {
  source = "./modules/data_servers"

  region            = var.data_servers_region
  vm_count          = var.data_servers_count
  name_prefix       = var.data_servers_name_prefix
  network_id        = coalesce(var.data_servers_network_id, module.network.network.id)
  image_name        = var.data_servers_image_name
  flavor_name       = var.data_servers_flavor_name
  key_pair          = var.data_servers_key_pair
  availability_zone = var.data_servers_availability_zone
  metadata          = var.data_servers_metadata
  user_data         = var.data_servers_user_data
  config_drive      = var.data_servers_config_drive

  volumes_enabled      = var.data_servers_volumes_enabled
  data_volume_size     = var.data_servers_volume_size
  data_volume_metadata = var.data_servers_volume_metadata
  attach_fip           = var.data_servers_attach_fip

  allowed_ingress_cidrs     = var.data_servers_allowed_ingress_cidrs
  allowed_ingress_tcp_ports = var.data_servers_allowed_ingress_tcp_ports
  allowed_ingress_udp_ports = var.data_servers_allowed_ingress_udp_ports
  allowed_egress_cidrs      = var.data_servers_allowed_egress_cidrs

  loadbalancer_name                   = var.data_servers_loadbalancer_name
  loadbalancer_flavor_id              = var.data_servers_loadbalancer_flavor_id
  lb_vip_subnet_id                    = coalesce(var.data_servers_lb_vip_subnet_id, module.network.subnets[0].id)
  lb_member_subnet_id                 = coalesce(var.data_servers_lb_member_subnet_id, module.network.subnets[0].id)
  loadbalancer_listener_protocol      = var.data_servers_lb_listener_protocol
  loadbalancer_listener_port          = var.data_servers_lb_listener_port
  loadbalancer_pool_protocol          = var.data_servers_lb_pool_protocol
  loadbalancer_lb_method              = var.data_servers_lb_method
  loadbalancer_member_port            = var.data_servers_lb_member_port
  loadbalancer_monitor_type           = var.data_servers_lb_monitor_type
  loadbalancer_monitor_delay          = var.data_servers_lb_monitor_delay
  loadbalancer_monitor_timeout        = var.data_servers_lb_monitor_timeout
  loadbalancer_monitor_max_retries    = var.data_servers_lb_monitor_max_retries
  loadbalancer_monitor_url_path       = var.data_servers_lb_monitor_url_path
  loadbalancer_monitor_expected_codes = var.data_servers_lb_monitor_expected_codes
  attach_lb_vip_fip                   = var.data_servers_attach_lb_vip_fip
}
