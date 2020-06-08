variable S3_BUCKET {}

variable VERSIONING_ENABLED {
  default = true
}

variable "TAGS" {
  type = map
}

resource "aws_s3_bucket" "this" {
  bucket = var.S3_BUCKET
  acl    = "private"

  versioning {
    enabled = var.VERSIONING_ENABLED
  }

  lifecycle_rule {
    enabled = false

    abort_incomplete_multipart_upload_days = 14

    expiration {
      expired_object_delete_marker = true
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      days = 365
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(
    var.TAGS,
    map(
      "Name", var.S3_BUCKET
    )
  )
}

output "id" {
  value = aws_s3_bucket.this.id
}

output "arn" {
  value = aws_s3_bucket.this.arn
}

output "fqdn" {
  value = aws_s3_bucket.this.bucket_domain_name
}

output "name" {
  value = aws_s3_bucket.this.tags["Name"]
}
