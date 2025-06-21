# vpc.tf

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

data "aws_vpc" "main" {
  id         = var.vpc_id
}

resource "aws_security_group" "ssh_enable" {
  vpc_id = data.aws_vpc.main.id
  name   = "ssh-enable-aoiorio"
}

resource "aws_vpc_security_group_egress_rule" "ssh_enable" {
  security_group_id = aws_security_group.ssh_enable.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  ip_protocol = "tcp"
  to_port     = 22
}

resource "aws_vpc_security_group_ingress_rule" "ssh_enable" {
  security_group_id = aws_security_group.ssh_enable.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
}
