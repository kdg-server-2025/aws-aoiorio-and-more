
terraform {
  required_version = "1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.97.0"
    }
  }

  backend "s3" {
    bucket  = "kdg-aws-2025-aoiorio"
    key     = "tfstate/develop.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}

provider "aws" {
  region  = "ap-northeast-1"
}

# data "aws_ecr_authorization_token" "token" {
#   user_name = ""
#   password = ""
# }

provider "docker" {
  registry_auth {
    address  = "${var.aws_caller_identity}.dkr.ecr.ap-northeast-1.amazonaws.com"
    username = var.aws_ecr_authorization_token.token.user_name
    password = var.aws_ecr_authorization_token.token.password
  }
}