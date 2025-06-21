resource "aws_sns_topic" "budget_alarm" {
  name = "atom-updates-topic"
}

resource "aws_sns_topic_subscription" "topic_subscription_atom" {
  topic_arn = aws_sns_topic.budget_alarm.arn
  protocol  = "email"
  endpoint  = var.private.email
}

resource "aws_budgets_budget" "cost" {
  name              = "you-are-running-out-of-money"
  budget_type       = "COST"
  limit_amount      = "5"
  limit_unit        = "USD"
  time_period_end   = "2087-06-15_00:00"
  time_period_start = "2017-07-01_00:00"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 5
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alarm.arn]
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# resource "aws_ecr_repository" "python_repo_for_lambda" {
#   name                 = "python-repo-for-lambda"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name  = "hello-lambda-api"
  create_package = false

  image_uri    = module.docker_image.image_uri
  package_type = "Image"
  memory_size = 10240
  timeout = 15

  depends_on = [module.docker_image]
}

module "docker_image" {
  source = "terraform-aws-modules/lambda/aws//modules/docker-build"

  create_ecr_repo = true
  ecr_repo        = "hello-lambda-api-repo"

  use_image_tag = true
  image_tag     = "1.0"

  triggers = {
    redeployment = timestamp()
  }

  source_path = "./api"
}

# resource "aws_lambda_function" "hello_lambda_func" {
#   function_name = "hello-lambda-func"
#   role          = aws_iam_role.iam_for_lambda.arn
#   runtime       = "python3.13"
#   handler       = "app.handler"
#   source_code_hash = data.archive_file.function_source.output_base64sha256
#   package_type  = "Image"
#   image_uri     = "${aws_ecr_repository.python_repo_for_lambda.repository_url}:latest"

#   ephemeral_storage {
#     size = 10240 # Min 512 MB and the Max 10240 MB
#   }
# }
