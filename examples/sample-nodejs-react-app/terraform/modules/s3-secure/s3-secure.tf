variable BUCKET {}

variable VERSIONING {
  default = true
}

variable "SSM_PATH" {}

variable "ACL" {}

variable "TAGS" {
  type = "map"
}

resource "aws_s3_bucket" "this" {
  bucket = "${var.BUCKET}"
  acl    = "${var.ACL}"

  versioning {
    enabled = "${var.VERSIONING}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = "${merge(
    var.TAGS,
    map(
      "Name", "${var.BUCKET}"
    )
  )}"
}

########
# Creating the policy
#########
resource "aws_s3_bucket_policy" "this" {
  bucket = "${aws_s3_bucket.this.id}"

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Deny",
            "Principal": {
                "AWS": "*"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${var.BUCKET}/*",
            "Condition": {
                "Bool": {
                    "aws:SecureTransport": "false"
                }
            }
        }
    ]
}
POLICY
}
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = "${aws_s3_bucket.this.id}"
  block_public_acls       = "true"
  block_public_policy     = "true"
  ignore_public_acls      = "true"
  restrict_public_buckets = "true"
}

resource "aws_ssm_parameter" "s3" {
  name      = "${var.SSM_PATH}"
  type      = "String"
  value     = "${aws_s3_bucket.this.id}"
  overwrite = true
}

output "arn" {
  value = "${aws_s3_bucket.this.arn}"
}

output "id" {
  value = "${aws_s3_bucket.this.id}"
}