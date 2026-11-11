module "s3" {
  source = "../../modules/s3"

  bucket_name  = var.s3_bucket_name
  environment  = var.environment
  project_name = var.project_name
}
