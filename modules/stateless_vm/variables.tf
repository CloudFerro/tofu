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
  default     = "stateless-vm"
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

variable "config_drive" {
  description = "Whether to enable config drive."
  type        = bool
  default     = false
}

variable "user_data" {
  description = "Optional cloud-init or user-data content."
  type        = string
  default     = null
}

variable "security_group_id" {
  description = "Security group UUID to attach to VM ports. This module does not create security groups."
  type        = string

  validation {
    condition     = length(trim(var.security_group_id, " ")) > 0
    error_message = "security_group_id must not be empty."
  }
}

variable "attach_fip" {
  description = "Whether to allocate and associate a floating IP from network external for each VM."
  type        = bool
  default     = false
}

# ---------------------------------------------------------------------------
# Classification metadata
# ---------------------------------------------------------------------------

variable "created_by" {
  description = "Username who created the VM. Set via TF_VAR_stateless_vm_created_by=$OS_USERNAME in shell."
  type        = string
  default     = "unknown"
}

variable "client_project" {
  description = "Business project name for cost classification."
  type        = string

  validation {
    condition     = length(trim(var.client_project, " ")) > 0
    error_message = "client_project must not be empty."
  }
}

variable "extra_metadata" {
  description = "Optional additional metadata key-value pairs merged with classification metadata."
  type        = map(string)
  default     = {}
}
