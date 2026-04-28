data_servers_region                     = null
data_servers_count                      = 2
data_servers_name_prefix                = "data-server"
#data_servers_network_id                 = "UUID-OF-TENANT-NETWORK"#optional if used without network module

data_servers_image_name                 = "Ubuntu 22.04 LTS"
data_servers_flavor_name                = "eo2a.medium"
data_servers_key_pair                   = "my-key"
data_servers_availability_zone          = null
data_servers_metadata                   = {}
data_servers_user_data                  = null
data_servers_config_drive               = false

data_servers_volumes_enabled            = false
data_servers_volume_size                = 20
data_servers_volume_metadata            = {}
data_servers_attach_fip                 = false

data_servers_allowed_ingress_cidrs = [
  "0.0.0.0/0"
]
data_servers_allowed_ingress_tcp_ports = [
  22,
  80
]
data_servers_allowed_ingress_udp_ports = []
data_servers_allowed_egress_cidrs = [
  "0.0.0.0/0"
]

data_servers_loadbalancer_name          = "data-servers-lb"
data_servers_loadbalancer_flavor_id     = "UUID-OF-LOADBALANCER-FLAVOR"
data_servers_lb_vip_subnet_id           = null
data_servers_lb_member_subnet_id        = null
data_servers_lb_listener_protocol       = "TCP"
data_servers_lb_listener_port           = 80
data_servers_lb_pool_protocol           = "TCP"
data_servers_lb_method                  = "ROUND_ROBIN"
data_servers_lb_member_port             = 80
data_servers_lb_monitor_type            = "PING"
data_servers_lb_monitor_delay           = 10
data_servers_lb_monitor_timeout         = 5
data_servers_lb_monitor_max_retries     = 3
data_servers_lb_monitor_url_path        = null
data_servers_lb_monitor_expected_codes  = null
data_servers_attach_lb_vip_fip          = true

