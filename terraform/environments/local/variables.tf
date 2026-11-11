variable "aws_region" {
  description = "The target AWS region for local emulation"
  type        = string
  default     = "ap-south-1"
}

variable "floci_endpoint" {
  description = "The base URL for the local Floci AWS emulator"
  type        = string
  default     = "http://localhost:4566"
}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for incoming file storage"
  type        = string
  default     = "file-processing-ingest-local"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.s3_bucket_name))
    error_message = "The s3_bucket_name must be between 3 and 63 characters long and contain only lowercase letters, numbers, hyphens, and periods, starting and ending with a letter or number."
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
