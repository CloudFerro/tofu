# Root-level variable declarations.
# Non-sensitive values come from bucket.auto.tfvars,
# sensitive provider values from providers.auto.tfvars.

variable "bucket" {
  description = "Configuration of the OpenStack object storage container."
  type = object({
    name               = string
    content_type       = optional(string)
    container_read     = optional(string)
    container_sync_key = optional(string)
    container_sync_to  = optional(string)
    container_write    = optional(string)
    force_destroy      = optional(bool, false)
    metadata           = optional(map(string), {})
    object_versioning  = optional(bool)
    quota_bytes        = optional(number)
    quota_count        = optional(number)
    region             = optional(string)
    storage_policy     = optional(string)
    versions_location  = optional(string)
  })

  validation {
    condition     = length(trim(var.bucket.name, " ")) > 0
    error_message = "bucket.name must not be empty."
  }
}

variable "ec2_credential_count" {
  description = "Number of EC2 credential pairs to create."
  type        = number
  default     = 4
}

variable "ec2_credential_project_id" {
  description = "Optional project ID scope for EC2 credentials."
  type        = string
  default     = null
}

variable "ec2_credential_user_id" {
  description = "Optional user ID for EC2 credentials."
  type        = string
  default     = null
}

variable "ec2_credential_region" {
  description = "Optional region for EC2 credentials."
  type        = string
  default     = null
}
