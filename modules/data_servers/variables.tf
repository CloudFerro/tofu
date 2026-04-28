variable "region" {
  description = "OpenStack region for all resources. When null, provider region is used."
  type        = string
  default     = null
}

variable "vm_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 2

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count must be >= 1."
  }
}

variable "name_prefix" {
  description = "Prefix used to build VM, port and volume names."
  type        = string
  default     = "data-server"
}

variable "network_id" {
  description = "Tenant network ID where VM ports will be created."
  type        = string

  validation {
    condition     = length(trim(var.network_id, " ")) > 0
    error_message = "network_id must not be empty."
  }
}

variable "image_name" {
  description = "Image name used to boot the virtual machines."
  type        = string
}

variable "flavor_name" {
  description = "Flavor name used for the virtual machines."
  type        = string
}

variable "key_pair" {
  description = "Optional key pair name injected into the virtual machines."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Optional availability zone for the virtual machines."
  type        = string
  default     = null
}

variable "metadata" {
  description = "Optional metadata assigned to all virtual machines."
  type        = map(string)
  default     = {}
}

variable "user_data" {
  description = "Optional cloud-init or user-data content."
  type        = string
  default     = null
}

variable "config_drive" {
  description = "Whether config drive should be enabled for the virtual machines."
  type        = bool
  default     = false
}

variable "volumes_enabled" {
  description = "Whether data volumes should be created and attached to virtual machines."
  type        = bool
  default     = true
}

variable "data_volume_size" {
  description = "Size of the data volume attached to each virtual machine, in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.data_volume_size >= 1
    error_message = "data_volume_size must be >= 1."
  }
}

variable "data_volume_metadata" {
  description = "Optional metadata assigned to all data volumes."
  type        = map(string)
  default     = {}
}

variable "attach_fip" {
  description = "Whether a floating IP from network 'external' should be allocated and associated to each virtual machine."
  type        = bool
  default     = false
}

variable "allowed_ingress_cidrs" {
  description = "List of CIDR ranges allowed on ingress TCP/UDP and ICMP rules."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.allowed_ingress_cidrs) > 0
    error_message = "allowed_ingress_cidrs must contain at least one CIDR."
  }
}

variable "allowed_ingress_tcp_ports" {
  description = "List of TCP ports allowed on ingress."
  type        = list(number)
  default     = [22, 80]
}

variable "allowed_ingress_udp_ports" {
  description = "List of UDP ports allowed on ingress. Empty list means no UDP ingress rules."
  type        = list(number)
  default     = []
}

variable "allowed_egress_cidrs" {
  description = "List of CIDR ranges allowed on egress."
  type        = list(string)
  default     = ["0.0.0.0/0"]

  validation {
    condition     = length(var.allowed_egress_cidrs) > 0
    error_message = "allowed_egress_cidrs must contain at least one CIDR."
  }
}

variable "loadbalancer_name" {
  description = "Load balancer name."
  type        = string
  default     = "data-servers-lb"
}

variable "loadbalancer_flavor_id" {
  description = "Flavor ID of the Octavia load balancer."
  type        = string
}

variable "lb_vip_subnet_id" {
  description = "Subnet ID used by the load balancer VIP."
  type        = string
}

variable "lb_member_subnet_id" {
  description = "Subnet ID used for load balancer members."
  type        = string
}

variable "loadbalancer_listener_protocol" {
  description = "Listener protocol."
  type        = string
  default     = "TCP"
}

variable "loadbalancer_listener_port" {
  description = "Listener port."
  type        = number
  default     = 80
}

variable "loadbalancer_pool_protocol" {
  description = "Pool protocol."
  type        = string
  default     = "TCP"
}

variable "loadbalancer_lb_method" {
  description = "Load balancing method."
  type        = string
  default     = "ROUND_ROBIN"
}

variable "loadbalancer_member_port" {
  description = "Backend member port."
  type        = number
  default     = 80
}

variable "loadbalancer_monitor_type" {
  description = "Health monitor type."
  type        = string
  default     = "TCP"
}

variable "loadbalancer_monitor_delay" {
  description = "Health monitor delay."
  type        = number
  default     = 10
}

variable "loadbalancer_monitor_timeout" {
  description = "Health monitor timeout."
  type        = number
  default     = 5
}

variable "loadbalancer_monitor_max_retries" {
  description = "Health monitor max retries."
  type        = number
  default     = 3
}

variable "loadbalancer_monitor_url_path" {
  description = "Optional health monitor URL path for HTTP/HTTPS monitors."
  type        = string
  default     = null
}

variable "loadbalancer_monitor_expected_codes" {
  description = "Optional expected HTTP response codes for HTTP/HTTPS monitors."
  type        = string
  default     = null
}

variable "attach_lb_vip_fip" {
  description = "Whether a floating IP from network 'external' should be associated to the load balancer VIP port."
  type        = bool
  default     = false
}
