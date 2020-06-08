variable SECGRP_NAME {
}

variable MY_IP {
}

variable VPC_ID {
}


resource "aws_security_group" "this" {
  name        = var.SECGRP_NAME
  description = "SecGroup for Engineer EC2 instance"
  vpc_id      = var.VPC_ID

  ingress {
    # TLS (change to whatever ports you need)
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.MY_IP] # add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 8081
    to_port   = 8081
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.MY_IP] # add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.MY_IP] # add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.MY_IP] # add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 8787
    to_port   = 8787
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.MY_IP] # add a CIDR block here
  }
  ingress {
    # TLS (change to whatever ports you need)
    from_port = 8081
    to_port   = 8081
    protocol  = "tcp"
    # Please restrict your ingress to only necessary IPs and ports.
    # Opening to 0.0.0.0/0 can lead to security vulnerabilities.
    cidr_blocks = [var.MY_IP] # add a CIDR block here
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # prefix_list_ids = ["pl-12c4e678"]
  }
  tags = merge(
    var.TAGS,
    map(
      "Name", var.SECGRP_NAME
    )
  )
}