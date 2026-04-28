variable "region" {
  description = "OpenStack region for all resources. When null, provider region is used."
  type        = string
  default     = null
}

variable "share_enabled" {
  description = "Whether the Manila share should be created."
  type        = bool
  default     = true
}

variable "name" {
  description = "Manila share name."
  type        = string

  validation {
    condition     = length(trim(var.name, " ")) > 0
    error_message = "name must not be empty."
  }
}

variable "description" {
  description = "Optional Manila share description."
  type        = string
  default     = null
}

variable "share_proto" {
  description = "Share protocol, for example NFS or CIFS."
  type        = string
  default     = "NFS"
}

variable "size" {
  description = "Share size in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.size >= 1
    error_message = "size must be >= 1."
  }
}

variable "share_network_id" {
  description = "Existing share network ID used by the Manila share."
  type        = string
  default     = null
}

variable "availability_zone" {
  description = "Optional availability zone for the Manila share."
  type        = string
  default     = null
}

variable "metadata" {
  description = "Optional metadata assigned to the share."
  type        = map(string)
  default     = {}
}

variable "allowed_instance_ips" {
  description = "List of instance IP addresses allowed in Manila share ACL."
  type        = list(string)
  default     = []
}

variable "access_level" {
  description = "Access level for ACL rules. Supported values are rw and ro."
  type        = string
  default     = "rw"

  validation {
    condition     = contains(["rw", "ro"], var.access_level)
    error_message = "access_level must be either rw or ro."
  }
}

variable "generate_mount_script" {
  description = "Whether the share mount script should be generated in the root files directory."
  type        = bool
  default     = true
}
