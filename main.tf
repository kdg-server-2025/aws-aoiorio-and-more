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
    subscriber_email_addresses = [var.private.email]
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

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "lambda_function_payload.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.test"
  runtime       = "nodejs18.x"

  ephemeral_storage {
    size = 10240 # Min 512 MB and the Max 10240 MB
  }
}