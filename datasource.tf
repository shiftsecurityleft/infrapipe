
data "aws_ami" "centos" {
  #executable_users = ["self"]
  most_recent = true
  name_regex  = "^CentOS Linux 7"
  owners      = ["aws-marketplace"]

  filter {
    name   = "product-code"
    values = ["aw0evgkw8e5c1q413zgy5pjce"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "this_centos_ami" {
  description = "The centos AMI"
  value       = "${data.aws_ami.centos.image_id}"
}

data "aws_ami_ids" "centos_amis" {
  owners = ["${data.aws_ami.centos.owner_id}"]

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA *"]
  }
}

output "this_centos_ami_ids" {
  description = "The centos AMIs"
  value       = "${data.aws_ami_ids.centos_amis.ids}"
}
