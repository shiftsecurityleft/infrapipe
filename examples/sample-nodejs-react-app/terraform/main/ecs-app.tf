variable APP_UUID {}
variable FAMILY {}
variable APP_IMAGE {}
variable APP_IMAGE_TAG {}
variable DOMAIN {}
variable APP_FULLNAME {}
variable APP_PREFIX {}

module "ecs" {
  source = "git::https://bitbucket.org/shiftsecurityleft/terraform-modules.git//ecs?ref=v2.0"

  VPC_NAME      = "${var.FAMILY}"
  DOMAIN        = "${var.DOMAIN}"
  APP_UUID      = "${var.APP_UUID}"
  APP_FULLNAME  = "${var.APP_FULLNAME}"
  APP_IMAGE     = "${var.APP_IMAGE}"
  APP_IMAGE_TAG = "${var.APP_IMAGE_TAG}"
  ROLE_NAME     = "${var.APP_PREFIX}"

  AUTOSHUTDOWN    = "10m"
  APP_PROTOCOL    = "HTTP"
  APP_PORT        = "3000"
  HEALTHCHECK_URI = "/status"
  APP_COUNT       = "2"
  CPU             = "512"
  MEMORY          = "1024"

  TAGS = "${local.common_tags}"

  #SECRETS = "${data.template_file.ssm.rendered}"

  ENVIRONMENT = "${data.template_file.env.rendered}"
}

/*
data "template_file" "ssm" {
  template = "${file("${path.cwd}/ssm.json.tpl")}"

  vars = {
    SSM_PATH = "${var.SSM_PATH}"

    # if the branch is feature branch, set APP_NAME and DNS_NAME is prefixed with same UUID.  
    SSM_APP_PATH = "${var.SSM_PATH}/${var.APP_NAME == var.DNS_NAME ? "default" : var.BITBUCKET_BRANCH}"
  }
}
*/

data "template_file" "env" {
  template = "${file("${path.cwd}/envvars.json.tpl")}"

  vars = {
    REPO_COMMIT_HASH     = "${local.common_tags["REPO_COMMIT_HASH"]}"
    REPO_COMMIT_DATETIME = "${local.common_tags["REPO_COMMIT_DATETIME"]}"
  }
}

output "app_url" {
  value = "${module.ecs.listener_https_url}"
}
