/*
variable "SSM_PATH" {
  description = "SSM Parameter to store S3 bucket name."
  type        = string
}
*/
/*
resource "random_pet" "this" {
  length = 2
}

module "log_bucket" {
  source = "git::https://gitlab.com/shiftsecurityleft/terraform-aws-templates/ssl-s3-bucket.git?ref=v0.3.0"

  bucket        = "logs-${random_pet.this.id}"
  acl           = "log-delivery-write"
  tags          = local.common_tags
  force_destroy = true
}

module "s3_test" {
  source = "git::https://gitlab.com/shiftsecurityleft/terraform-aws-templates/ssl-s3-bucket.git?ref=v0.3.0"

  bucket   = "demo-${random_pet.this.id}"
  ssm_path = var.SSM_PATH

  logging = {
    target_bucket = module.log_bucket.this_s3_bucket_id
    target_prefix = "log/"
  }
  tags          = local.common_tags
  force_destroy = true
}

output "arn" {
  description = "The ARN of the bucket. Will be of format arn:aws:s3:::bucketname."
  value       = module.s3_test.this_s3_bucket_arn
}
*/