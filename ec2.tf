data "aws_ami" "ubuntu-24-x86" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "kdg-aws-20250621-user-date-enable" {
  ami = data.aws_ami.ubuntu-24-x86.id
  #   無料枠を使うため、t3.microを使う
  instance_type = "t3.micro"

  tags = {
    Name     = "kdg-aws-20250621-user-date-enable",
    UserDate = "true"
  }

  vpc_security_group_ids      = [aws_security_group.ssh_enable.id]
  user_data_replace_on_change = true
  key_name                    = aws_key_pair.keypair.id
}
