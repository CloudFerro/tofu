variable "region" {
  description = "OpenStack region for all resources. When null, provider region is used."
  type        = string
  default     = null
}

variable "vm_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count must be >= 1."
  }
}

variable "name_prefix" {
  description = "Prefix used to build VM and port names."
  type        = string
  default     = "bastion"
}

variable "network_id" {
  description = "ID of the tenant network where VM ports will be created."
  type        = string

  validation {
    condition     = length(trim(var.network_id, " ")) > 0
    error_message = "network_id must not be empty."
  }
}

variable "image_name" {
  description = "Image name used to boot the virtual machines."
  type        = string

  validation {
    condition     = length(trim(var.image_name, " ")) > 0
    error_message = "image_name must not be empty."
  }
}

variable "flavor_name" {
  description = "Flavor name used for the virtual machines."
  type        = string

  validation {
    condition     = length(trim(var.flavor_name, " ")) > 0
    error_message = "flavor_name must not be empty."
  }
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

variable "allowed_tcp_ports" {
  description = "List of IPv4 TCP ingress ports allowed from any source."
  type        = list(number)
  default     = [22]

  validation {
    condition = alltrue([
      for port in var.allowed_tcp_ports : port >= 1 && port <= 65535
    ])
    error_message = "allowed_tcp_ports values must be between 1 and 65535."
  }
}

variable "attach_fip" {
  description = "Whether a floating IP from network 'external' should be allocated and associated to each virtual machine."
  type        = bool
  default     = false
}
