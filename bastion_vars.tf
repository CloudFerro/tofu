variable "bastion_region" {
  description = "Region for bastion resources."
  type        = string
  default     = null
}

variable "bastion_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 1
}

variable "bastion_name_prefix" {
  description = "Prefix used to build virtual machine names."
  type        = string
  default     = "bastion"
}

variable "bastion_network_id" {
  description = "Tenant network ID for virtual machine attachment."
  type        = string
  default     = null
}

variable "bastion_image_name" {
  description = "Image name for virtual machines."
  type        = string
}

variable "bastion_flavor_name" {
  description = "Flavor name for virtual machines."
  type        = string
}

variable "bastion_key_pair" {
  description = "Optional key pair for virtual machines."
  type        = string
  default     = null
}

variable "bastion_availability_zone" {
  description = "Optional availability zone."
  type        = string
  default     = null
}

variable "bastion_metadata" {
  description = "Optional metadata for all virtual machines."
  type        = map(string)
  default     = {}
}

variable "bastion_user_data" {
  description = "Optional user-data content."
  type        = string
  default     = null
}

variable "bastion_config_drive" {
  description = "Whether config drive should be enabled."
  type        = bool
  default     = false
}

variable "bastion_allowed_tcp_ports" {
  description = "List of IPv4 TCP ingress ports allowed from any source."
  type        = list(number)
  default     = [22]
}

variable "bastion_attach_fip" {
  description = "Whether to allocate and associate a floating IP from network external for each virtual machine."
  type        = bool
  default     = false
}

variable "bastion_guacamole_users" {
  description = "Users to create in Guacamole during first boot."
  type = list(object({
    username   = string
    password   = string
    disabled   = optional(bool, false)
    expired    = optional(bool, false)
    attributes = optional(map(string), {})
  }))
  default   = []
  sensitive = true

  validation {
    condition     = length(var.bastion_guacamole_users) == length(distinct([for user in var.bastion_guacamole_users : user.username]))
    error_message = "Each Guacamole username must be unique."
  }
}

variable "bastion_guacamole_connections" {
  description = "Connections to create in Guacamole during first boot."
  type = list(object({
    name              = string
    protocol          = string
    parent_identifier = optional(string, "ROOT")
    parameters        = map(string)
    attributes        = optional(map(string), {})
    users             = optional(list(string), [])
  }))
  default = []

  validation {
    condition     = length(var.bastion_guacamole_connections) == length(distinct([for connection in var.bastion_guacamole_connections : format("%s::%s", connection.parent_identifier, connection.name)]))
    error_message = "Each Guacamole connection name must be unique within its parent identifier."
  }
}

variable "bastion_guacamole_openstack_instances" {
  description = "Optional inventory of OpenStack instances that should be converted into Guacamole connections automatically."
  type = list(object({
    name              = string
    address           = string
    protocol          = optional(string, "ssh")
    port              = optional(number)
    username          = optional(string)
    password          = optional(string)
    private_key       = optional(string)
    parent_identifier = optional(string, "ROOT")
    users             = optional(list(string), [])
    parameters        = optional(map(string), {})
    attributes        = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for instance in var.bastion_guacamole_openstack_instances : contains(["ssh", "rdp", "vnc", "telnet", "kubernetes"], instance.protocol)
    ])
    error_message = "bastion_guacamole_openstack_instances protocol must be one of: ssh, rdp, vnc, telnet, kubernetes."
  }

  validation {
    condition = alltrue([
      for instance in var.bastion_guacamole_openstack_instances : try(instance.port, null) == null || (instance.port >= 1 && instance.port <= 65535)
    ])
    error_message = "bastion_guacamole_openstack_instances port values must be between 1 and 65535 when set."
  }
}
