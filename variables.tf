variable "email" {
  description = "notification email"
  type        = string
}

variable "iam_for_lambda_arn" {
  description = "iam role for lambda arn"
  type        = string
}

# variable "ssh_key" {
#   description = "we will use this SSH Key"
#   type        = string
# }

# variable "key_name" {
#   type = string
# }

# resource "aws_key_pair" "keypair" {
#   key_name = var.key_name
#   public_key = var.ssh_key
# }
