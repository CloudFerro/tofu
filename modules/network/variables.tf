variable "region" {
  description = "OpenStack region for all networking resources. When null, provider region is used."
  type        = string
  default     = null
}

variable "network_name" {
  description = "Name of the tenant network to create."
  type        = string

  validation {
    condition     = length(trim(var.network_name, " ")) > 0
    error_message = "network_name must not be empty."
  }
}

variable "router_name" {
  description = "Name of the router to create."
  type        = string
  default     = "router-1"
}

variable "external_network_id" {
  description = <<-EOT
    ID of the external network used for router external gateway.
    This must refer to an existing external network in Neutron.
  EOT
  type = string

  validation {
    condition     = length(trim(var.external_network_id, " ")) > 0
    error_message = "external_network_id must not be empty."
  }
}

variable "subnets" {
  description = <<-EOT
    List of subnets to create in the tenant network.
    Supports both IPv4 and IPv6 depending on ip_version.
  EOT

  type = list(object({
    name      = string
    cidr      = string
    ip_version = number # 4 or 6

    enable_dhcp = optional(bool, true)

    gateway_ip      = optional(string)
    dns_nameservers = optional(list(string), [])

    allocation_pools = optional(list(object({
      start = string
      end   = string
    })), [])

    # Only relevant for ip_version = 6
    ipv6_address_mode = optional(string)
    ipv6_ra_mode      = optional(string)
  }))

  validation {
    condition     = length(var.subnets) >= 1
    error_message = "At least one subnet must be defined."
  }
}