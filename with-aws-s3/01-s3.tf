module "private_bucket" {
  source              = "clouddrove/s3/aws"
  version             = "0.15.2"
  name                = "use-terraform"
  environment         = "test"
  label_order         = ["name", "environment"]
  versioning          = true
  acl                 = "private"
}

output "bucket-url" {
  description = "S3 Bucket URL"
  value = module.private_bucket.bucket_domain_name
}