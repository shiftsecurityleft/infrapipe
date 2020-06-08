
data "aws_caller_identity" "current" {}
variable ROLE_NAME {}
variable SSM_PATH {}

variable S3_LIST {
  type = list
}


variable "TAGS" {
  type = map
}

resource "aws_iam_instance_profile" "this" {
  name = var.ROLE_NAME
  role = aws_iam_role.this.name
}
resource "aws_iam_role" "this" {
  name        = var.ROLE_NAME
  description = "Role to be used by Engineer"
  path        = var.SSM_PATH

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    var.TAGS,
    map(
      "Name", var.ROLE_NAME
    )
  )
}

resource "aws_iam_role_policy" "this" {
  name = var.ROLE_NAME
  role = aws_iam_role.this.id

  policy = data.template_file.role_policy.rendered
}

data "template_file" "role_policy" {
  template = file("${path.module}/role_policy.json.tpl")

  vars = {
    S3_LIST          = join(",", formatlist("\"%s\"", var.S3_LIST))
    THIS_AWS_ACCT_ID = data.aws_caller_identity.current.account_id
  }
}

output "this_iam_role_id" {
  description = "The ID of this Instance Profile IAM role"
  value       = aws_iam_role.this.arn
}