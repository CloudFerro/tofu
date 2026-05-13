ha_tier_region                     = null
ha_tier_count                      = 2
ha_tier_name_prefix                = "ha-tier"
ha_tier_network_id                 = "UUID-OF-TENANT-NETWORK"

ha_tier_image_name                 = "Ubuntu 22.04 LTS"
ha_tier_flavor_name                = "eo2a.medium"
ha_tier_key_pair                   = "my-key"
ha_tier_availability_zone          = null
ha_tier_metadata                   = {}
ha_tier_user_data                  = null
ha_tier_config_drive               = false

ha_tier_attach_fip                 = false

ha_tier_allowed_ingress_cidrs = [
  "0.0.0.0/0"
]
ha_tier_allowed_ingress_tcp_ports = [
  22,
  8000
]
ha_tier_allowed_ingress_udp_ports = []
ha_tier_allowed_egress_cidrs = [
  "0.0.0.0/0"
]

ha_tier_loadbalancer_name          = "ha-tier-lb"
ha_tier_loadbalancer_flavor_id     = "UUID-OF-LOADBALANCER-FLAVOR"
ha_tier_lb_vip_subnet_id           = "UUID-OF-TENANT-NETWORK-SUBNET"
ha_tier_lb_member_subnet_id        = "UUID-OF-TENANT-NETWORK-SUBNET"
ha_tier_lb_listener_protocol       = "TCP"
ha_tier_lb_listener_port           = 8000
ha_tier_lb_pool_protocol           = "TCP"
ha_tier_lb_method                  = "ROUND_ROBIN"
ha_tier_lb_member_port             = 8000
ha_tier_lb_monitor_type            = "PING"
ha_tier_lb_monitor_delay           = 10
ha_tier_lb_monitor_timeout         = 5
ha_tier_lb_monitor_max_retries     = 3
ha_tier_lb_monitor_url_path        = null
ha_tier_lb_monitor_expected_codes  = null
ha_tier_attach_lb_vip_fip          = false

