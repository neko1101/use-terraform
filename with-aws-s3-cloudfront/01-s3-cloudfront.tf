# https://registry.terraform.io/modules/babbel/cloudfront-bucket/aws/latest
module "s3-cloudfront" {
  source  = "babbel/cloudfront-bucket/aws"
  version = "~> 1.0"

  bucket_name = "use-terraform-s3-cloudfront"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "cloudfront-cname" {
  description = "Cloudfront CNAME"
  value = module.s3-cloudfront.cloudfront_distribution.domain_name
}

output "s3-bucket" {
  description = "S3 Bucket Name"
  value = module.s3-cloudfront.bucket.bucket
}

output "s3-bucket-url" {
  description = "S3 Bucket URL"
  value = module.s3-cloudfront.bucket.bucket_domain_name
}