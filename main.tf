variable TESTSEP {}

resource "random_pet" "common" {
  length    = 2
  separator = var.TESTSEP
}

module "keys" {
  source   = "./modules/devops-productivity/ssh-key"
  KEY_NAME = "keypair-lostaunau"
  #TAGS = local.common_tags
}

output "this_ssh_keyname" {
  description = "The SSH keypair name"
  value       = "${module.keys.this_ssh_keyname}"
}

module "MyUserData" {
  source             = "./modules/devops-productivity/s3"
  VERSIONING_ENABLED = "false"
  S3_BUCKET          = "${random_pet.common.id}-lostaunau"
  TAGS               = local.common_tags
}

module "MyUserIAMRole" {
  source    = "./modules/devops-productivity/iam-instance-profile"
  ROLE_NAME = "${random_pet.common.id}-ec2-lostaunau"
  SSM_PATH  = "/ops/devops/"
  S3_LIST   = ["arn:aws:s3:::${random_pet.common.id}-lostaunau"]
  TAGS      = local.common_tags
}


module "ec2-personal-server" {
  source               = "./modules/devops-productivity/ec2"
  TAGS                 = local.common_tags
  KEYPAIR_NAME         = "keypair-lostaunau"
  EC2_INSTANCE_PROFILE = "${random_pet.common.id}-ec2-lostaunau"
  EC2_NAME             = "${random_pet.common.id}-server-clo"
  EC2_AMI              = "${data.aws_ami.centos.image_id}"
  VPC_ID               = "vpc-38fc6642"
  SECGRP_NAME          = "lostaunau-ssh-server"
  USER_DATA_PATH       = "${path.root}/modules/devops-productivity/userdata/centos_dev_gui.tmpl"
  MY_IP                = "68.190.225.38/32"

}


output "server_ec2_instance_id" {
  description = "The EC2 instance ID"
  value       = module.ec2-personal-server.this_ec2_instance_id
}

output "server_ec2_instance_ip" {
  description = "The EC2 IP address"
  value       = module.ec2-personal-server.this_ec2_instance_ip
}
/*
module "ec2-client" {
  source = "./modules/ec2"
  TAGS = local.common_tags
  KEYPAIR_NAME = "keypair-lostaunau"
  EC2_NAME = "${random_pet.common.id}-client-clo"
  SECGRP_NAME = "lostaunau-ssh"
  MY_IP = "68.190.225.38/32"

}
output "client_ec2_instance_id" {
  description = "The EC2 instance ID"
  value       = "${module.ec2-client.this_ec2_instance_id}"
}

output "client_ec2_instance_ip" {
  description = "The EC2 IP address"
  value       = "${module.ec2-client.this_ec2_instance_ip}"
}
*/


