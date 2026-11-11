output "s3_bucket_id" {
  description = "The name/ID of the created S3 bucket"
  value       = module.s3.bucket_id
}

output "s3_bucket_arn" {
  description = "The ARN of the created S3 bucket"
  value       = module.s3.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "The domain name of the created S3 bucket"
  value       = module.s3.bucket_domain_name
}
