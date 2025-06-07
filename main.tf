resource "aws_sns_topic" "user_updates" {
  name = "user-updates-topic"
}

resource "aws_sqs_queue" "user_updates_queue" {
  name   = "user-updates-queue"
  policy = data.aws_iam_policy_document.sqs_queue_policy.json
}

resource "aws_sns_topic_subscription" "user_updates_queue" {
  topic_arn = aws_sns_topic.user_updates.arn
  protocol  = "email"
  endpoint  = var.private.email
}

data "aws_iam_policy_document" "sqs_queue_policy" {
  policy_id = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"

  statement {
    sid    = "user_updates_sqs_target"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    actions = [
      "SQS:SendMessage",
    ]

    resources = [
      "arn:aws:iam::aws:policy/AmazonSQSFullAccess",
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.user_updates.arn,
      ]
    }
  }
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
    subscriber_sns_topic_arns  = [var.sns.subscriber-sns-topic-arns]
  }
}
