terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region     = var.aws_region
  access_key = "test"
  secret_key = "test"

  # S3 path-style addressing:
  # Forces requests to use path-style URLs (http://localhost:4566/<bucket>/<key>)
  # rather than virtual-hosted bucket URLs (<bucket>.localhost:4566/<key>),
  # which is required for local emulators without custom local DNS resolution.
  s3_use_path_style = true

  # Provider validation skips for local emulation:
  # - skip_credentials_validation: Prevents calling AWS STS to validate test credentials against real AWS.
  # - skip_metadata_api_check: Disables connection attempts to the EC2 Instance Metadata Service (IMDS).
  # - skip_requesting_account_id: Avoids making STS GetCallerIdentity API calls to retrieve an AWS Account ID.
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  # Explicit endpoint overrides targeting the local Floci emulator.
  # Explicitly mapping all required services prevents any implicit fallback
  # or outbound network traffic to real AWS endpoints.
  endpoints {
    cloudwatch     = var.floci_endpoint
    cloudwatchlogs = var.floci_endpoint
    dynamodb       = var.floci_endpoint
    iam            = var.floci_endpoint
    lambda         = var.floci_endpoint
    s3             = var.floci_endpoint
    sqs            = var.floci_endpoint
    sts            = var.floci_endpoint
  }
}
