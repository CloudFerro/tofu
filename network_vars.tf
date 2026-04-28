variable "network_region" {
  description = "Region for networking resources; null => provider default."
  type        = string
  default     = null
}

variable "network_name" {
  description = "Tenant network name."
  type        = string
}

variable "router_name" {
  description = "Router name."
  type        = string
  default     = "router-1"
}

variable "external_network_id" {
  description = "Existing external network ID for router gateway."
  type        = string
}

variable "subnets" {
  description = "List of tenant network subnets (IPv4/IPv6)."
  type = list(object({
    name       = string
    cidr       = string
    ip_version = number

    enable_dhcp = optional(bool, true)

    gateway_ip      = optional(string)
    dns_nameservers = optional(list(string), [])

    allocation_pools = optional(list(object({
      start = string
      end   = string
    })), [])

    ipv6_address_mode = optional(string)
    ipv6_ra_mode      = optional(string)
  }))
}
