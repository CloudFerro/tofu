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
  description = "Number of EC2 credential sets to create (access + secret key pairs)."
  type        = number
  default     = 4

  validation {
    condition     = var.ec2_credential_count >= 1
    error_message = "ec2_credential_count must be >= 1."
  }
}

variable "ec2_credential_project_id" {
  description = <<-EOT
    Optional project ID for which the EC2 credentials will be scoped.
    When null, credentials are scoped to the current auth project.
    Only administrative users can set a project ID different from the current scope.
  EOT
  type        = string
  default     = null
}

variable "ec2_credential_user_id" {
  description = <<-EOT
    Optional user ID to create the EC2 credentials for.
    When null, credentials are created for the current authenticated user.
    Only administrative users can set a user ID different from the current scope.
  EOT
  type        = string
  default     = null
}

variable "ec2_credential_region" {
  description = "OpenStack region for the EC2 credentials. Defaults to the provider region when null."
  type        = string
  default     = null
}
