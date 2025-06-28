resource "aws_sns_topic" "budget_alarm" {
  name = "atom-updates-topic"
}

resource "aws_sns_topic_subscription" "topic_subscription_atom" {
  topic_arn = aws_sns_topic.budget_alarm.arn
  protocol  = "email"
  endpoint  = var.email
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
    subscriber_email_addresses = [var.email]
    subscriber_sns_topic_arns  = [aws_sns_topic.budget_alarm.arn]
  }
}
