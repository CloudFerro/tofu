variable "stateless_vm_region" {
  description = "Region for stateless_vm resources."
  type        = string
  default     = null
}

variable "stateless_vm_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 1
}

variable "stateless_vm_name_prefix" {
  description = "Prefix used to build virtual machine names."
  type        = string
  default     = "stateless-vm"
}

variable "stateless_vm_network_id" {
  description = "Tenant network ID for virtual machine attachment."
  type        = string
  default     = null
}

variable "stateless_vm_image_name" {
  description = "Image name for virtual machines."
  type        = string
}

variable "stateless_vm_flavor_name" {
  description = "Flavor name for virtual machines."
  type        = string
}

variable "stateless_vm_key_pair" {
  description = "Optional key pair for virtual machines."
  type        = string
  default     = null
}

variable "stateless_vm_availability_zone" {
  description = "Optional availability zone for virtual machines."
  type        = string
  default     = null
}

variable "stateless_vm_config_drive" {
  description = "Whether to enable config drive."
  type        = bool
  default     = false
}

variable "stateless_vm_user_data" {
  description = "Optional user-data content."
  type        = string
  default     = null
}

variable "stateless_vm_security_group_id" {
  description = "Security group UUID to attach to VM ports."
  type        = string
}

variable "stateless_vm_attach_fip" {
  description = "Whether to allocate and associate a floating IP for each VM."
  type        = bool
  default     = false
}

variable "stateless_vm_created_by" {
  description = "Username who created the VM. Set via TF_VAR_stateless_vm_created_by=$OS_USERNAME."
  type        = string
  default     = "unknown"
}

variable "stateless_vm_client_project" {
  description = "Business project name for cost classification."
  type        = string
}

variable "stateless_vm_extra_metadata" {
  description = "Optional additional metadata key-value pairs."
  type        = map(string)
  default     = {}
}
