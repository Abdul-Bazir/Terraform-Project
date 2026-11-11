variable "bucket_name" {
  description = "Name of the S3 bucket. Must follow standard AWS S3 naming conventions."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "The bucket_name must be between 3 and 63 characters long and contain only lowercase letters, numbers, hyphens, and periods, starting and ending with a letter or number."
  }
}

variable "environment" {
  description = "Deployment environment name (e.g., local, dev, prod)"
  type        = string
  default     = "local"
}

variable "project_name" {
  description = "Name of the project to tag resources with"
  type        = string
  default     = "event-driven-file-processing"
}

