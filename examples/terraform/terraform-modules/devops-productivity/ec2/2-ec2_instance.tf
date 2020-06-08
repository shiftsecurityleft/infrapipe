
variable EC2_NAME {
}

variable KEYPAIR_NAME {
}

variable EC2_INSTANCE_PROFILE {
}
variable "TAGS" {
  type = map
}

variable USER_DATA_PATH {
}
variable EC2_AMI {
}
resource "aws_instance" "this" {
  ami                    = var.EC2_AMI
  instance_type          = "t2.large"
  iam_instance_profile   = var.EC2_INSTANCE_PROFILE
  key_name               = var.KEYPAIR_NAME
  vpc_security_group_ids = [aws_security_group.this.id]
  user_data              = templatefile("${var.USER_DATA_PATH}", { port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })
  root_block_device {
    volume_type = "gp2"
    volume_size = "150"
    #iops                  = local.root_iops
    delete_on_termination = true
  }

  tags = merge(
    var.TAGS,
    map(
      "Name", var.EC2_NAME
    )
  )
}

output "this_ec2_instance_id" {
  description = "The EC2 instance ID"
  value       = aws_instance.this.id
}
output "this_ec2_instance_ip" {
  description = "The EC2 IP address"
  value       = aws_instance.this.public_ip
}
