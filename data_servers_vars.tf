variable "data_servers_region" {
  description = "Region for data_servers resources."
  type        = string
  default     = null
}

variable "data_servers_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 2
}

variable "data_servers_name_prefix" {
  description = "Prefix used to build resource names."
  type        = string
  default     = "data-server"
}

variable "data_servers_network_id" {
  description = "Optional tenant network ID for data servers. If null, module.network.network.id is used."
  type        = string
  default     = null
}

variable "data_servers_image_name" {
  description = "Image name for virtual machines."
  type        = string
}

variable "data_servers_flavor_name" {
  description = "Flavor name for virtual machines."
  type        = string
}

variable "data_servers_key_pair" {
  description = "Optional key pair for virtual machines."
  type        = string
  default     = null
}

variable "data_servers_availability_zone" {
  description = "Optional availability zone."
  type        = string
  default     = null
}

variable "data_servers_metadata" {
  description = "Optional metadata for all virtual machines."
  type        = map(string)
  default     = {}
}

variable "data_servers_user_data" {
  description = "Optional user-data content."
  type        = string
  default     = null
}

variable "data_servers_config_drive" {
  description = "Whether config drive should be enabled."
  type        = bool
  default     = false
}

variable "data_servers_volumes_enabled" {
  description = "Whether data volumes should be created and attached to virtual machines."
  type        = bool
  default     = true
}

variable "data_servers_volume_size" {
  description = "Size of the data volume attached to each virtual machine, in GB."
  type        = number
  default     = 20
}

variable "data_servers_volume_metadata" {
  description = "Optional metadata for all data volumes."
  type        = map(string)
  default     = {}
}

variable "data_servers_attach_fip" {
  description = "Whether to allocate and associate a floating IP from network external for each virtual machine."
  type        = bool
  default     = false
}

variable "data_servers_allowed_ingress_cidrs" {
  description = "List of CIDR ranges allowed on ingress."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "data_servers_allowed_ingress_tcp_ports" {
  description = "List of TCP ports allowed on ingress."
  type        = list(number)
  default     = [22, 80]
}

variable "data_servers_allowed_ingress_udp_ports" {
  description = "List of UDP ports allowed on ingress."
  type        = list(number)
  default     = []
}

variable "data_servers_allowed_egress_cidrs" {
  description = "List of CIDR ranges allowed on egress."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "data_servers_loadbalancer_name" {
  description = "Load balancer name."
  type        = string
  default     = "data-servers-lb"
}

variable "data_servers_loadbalancer_flavor_id" {
  description = "Flavor ID of the load balancer."
  type        = string
}

variable "data_servers_lb_vip_subnet_id" {
  description = "Optional subnet ID used by the load balancer VIP. If null, the first subnet from module.network is used."
  type        = string
  default     = null
}

variable "data_servers_lb_member_subnet_id" {
  description = "Optional subnet ID used for load balancer members. If null, the first subnet from module.network is used."
  type        = string
  default     = null
}

variable "data_servers_lb_listener_protocol" {
  description = "Listener protocol."
  type        = string
  default     = "TCP"
}

variable "data_servers_lb_listener_port" {
  description = "Listener port."
  type        = number
  default     = 80
}

variable "data_servers_lb_pool_protocol" {
  description = "Pool protocol."
  type        = string
  default     = "TCP"
}

variable "data_servers_lb_method" {
  description = "Load balancing method."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "data_servers_lb_member_port" {
  description = "Backend member port."
  type        = number
  default     = 80
}

variable "data_servers_lb_monitor_type" {
  description = "Health monitor type."
  type        = string
  default     = "TCP"
}

variable "data_servers_lb_monitor_delay" {
  description = "Health monitor delay."
  type        = number
  default     = 10
}

variable "data_servers_lb_monitor_timeout" {
  description = "Health monitor timeout."
  type        = number
  default     = 5
}

variable "data_servers_lb_monitor_max_retries" {
  description = "Health monitor max retries."
  type        = number
  default     = 3
}

variable "data_servers_lb_monitor_url_path" {
  description = "Optional URL path for HTTP/HTTPS health monitors."
  type        = string
  default     = null
}

variable "data_servers_lb_monitor_expected_codes" {
  description = "Optional expected HTTP response codes for HTTP/HTTPS health monitors."
  type        = string
  default     = null
}

variable "data_servers_attach_lb_vip_fip" {
  description = "Whether to associate a floating IP from network external to the load balancer VIP."
  type        = bool
  default     = false
}
