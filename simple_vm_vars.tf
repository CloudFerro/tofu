variable "simple_vm_region" {
  description = "Region for simple_vm resources."
  type        = string
  default     = null
}

variable "simple_vm_count" {
  description = "Number of virtual machines to create."
  type        = number
  default     = 1
}

variable "simple_vm_name_prefix" {
  description = "Prefix used to build virtual machine names."
  type        = string
  default     = "simple-vm"
}

variable "simple_vm_network_id" {
  description = "Tenant network ID for virtual machine attachment."
  type        = string
  default     = null
}

variable "simple_vm_image_name" {
  description = "Image name for virtual machines."
  type        = string
}

variable "simple_vm_flavor_name" {
  description = "Flavor name for virtual machines."
  type        = string
}

variable "simple_vm_key_pair" {
  description = "Optional key pair for virtual machines."
  type        = string
  default     = null
}

variable "simple_vm_availability_zone" {
  description = "Optional availability zone."
  type        = string
  default     = null
}

variable "simple_vm_metadata" {
  description = "Optional metadata for all virtual machines."
  type        = map(string)
  default     = {}
}

variable "simple_vm_user_data" {
  description = "Optional user-data content."
  type        = string
  default     = null
}

variable "simple_vm_config_drive" {
  description = "Whether config drive should be enabled."
  type        = bool
  default     = false
}

variable "simple_vm_attach_fip" {
  description = "Whether to allocate and associate a floating IP from network external for each virtual machine."
  type        = bool
  default     = false
}
