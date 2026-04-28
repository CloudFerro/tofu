variable "share_region" {
  description = "Region for share resources."
  type        = string
  default     = null
}

variable "share_enabled" {
  description = "Whether the Manila share should be created."
  type        = bool
  default     = true
}

variable "share_name" {
  description = "Manila share name."
  type        = string
}

variable "share_description" {
  description = "Optional Manila share description."
  type        = string
  default     = null
}

variable "share_proto" {
  description = "Share protocol."
  type        = string
  default     = "NFS"
}

variable "share_size" {
  description = "Share size in GB."
  type        = number
  default     = 20
}

variable "share_network_id" {
  description = "Existing share network ID."
  type        = string
  default     = null
}

variable "share_availability_zone" {
  description = "Optional availability zone."
  type        = string
  default     = null
}

variable "share_metadata" {
  description = "Optional share metadata."
  type        = map(string)
  default     = {}
}

variable "share_allowed_instance_ips" {
  description = "List of instance IP addresses allowed in the share ACL."
  type        = list(string)
  default     = []
}

variable "share_access_level" {
  description = "ACL access level."
  type        = string
  default     = "rw"
}

variable "share_generate_mount_script" {
  description = "Whether the mount script should be generated in the root files directory."
  type        = bool
  default     = true
}

