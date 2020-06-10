variable FAMILY {}

data "aws_iam_account_alias" "current" {}

locals {
  alias = "${lower(data.aws_iam_account_alias.current.account_alias)}"
}

module "vpc" {
  source = "git::https://bitbucket.org/shiftsecurityleft/terraform-modules.git//vpc?ref=v2.0"

  VPC_NAME = "${var.FAMILY}"
  VPC_CIDR = "10.1.0.0/16"

  TAGS = "${local.common_tags}"
}

module "iam_role_demo" {
  source = "git::https://bitbucket.org/shiftsecurityleft/terraform-modules.git//iam/iam-apps/iam-ecs?ref=v2.0"

  APP_FAMILY = "${var.FAMILY}"
  APP_PREFIX = "demo-nodejs"

  TAGS = "${local.common_tags}"
}

module "lb-ext" {
  source = "git::https://bitbucket.org/shiftsecurityleft/terraform-modules.git//alb?ref=v2.0"

  LB_NAME  = "${var.FAMILY}-ext"
  DOMAIN   = "aws.shiftsecurityleft.cloud"
  VPC_NAME = "${module.vpc.vpc_name}"

  # Meaning it is external
  INTERNAL = false

  # Meaning not proxied by CloudFlare so DNS is purely controled by AWS Route53
  PROXYED = false

  #SOURCE_CIDRS = ["173.245.48.0/20", "103.21.244.0/22", "103.22.200.0/22", "103.31.4.0/22", "141.101.64.0/18", "108.162.192.0/18", "190.93.240.0/20", "188.114.96.0/20", "197.234.240.0/22", "198.41.128.0/17", "162.158.0.0/15", "104.16.0.0/12", "172.64.0.0/13", "131.0.72.0/22", "12.171.137.115/32", "199.120.242.115/32"]
  SOURCE_CIDRS = ["0.0.0.0/0"]

  TAGS = "${local.common_tags}"
}

module "s3_scan_results" {
  source = "../modules/s3-secure"

  BUCKET   = "${var.FAMILY}-scan-results-${local.alias}"
  SSM_PATH = "/app/${var.FAMILY}/SCANRESULTSBUCKET"

  ACL        = "private"
  VERSIONING = "true"

  TAGS = "${local.common_tags}"
}