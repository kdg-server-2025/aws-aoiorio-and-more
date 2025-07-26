resource "aws_cloudwatch_metric_alarm" "lambda_metric_alarm" {
  alarm_name                = "${aws_lambda_function.hello_go_function.function_name}-high-error-count-alarm"
  alarm_description         = "Errors increased in ${aws_lambda_function.hello_go_function.function_name}"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 2
  metric_name               = "ErrorEventCount"
  namespace                 = "ErrorMetrics"
  period                    = 60
  statistic                 = "Sum"
  threshold                 = 2
  actions_enabled           = "true"
  alarm_actions             = [aws_sns_topic.lambda_alarm_topic.arn]
  insufficient_data_actions = []

  tags = {
    Name = "${aws_lambda_function.hello_go_function.function_name}-high-error-count-alarm"
  }
}

# アラーム通知用のSNSトピックとサブシクリプション
resource "aws_sns_topic" "lambda_alarm_topic" {
  name = "${aws_lambda_function.hello_go_function.function_name}-alarm-topic"
}

resource "aws_sns_topic_subscription" "lambda_alarm" {
  topic_arn = aws_sns_topic.lambda_alarm_topic.arn
  protocol  = "email"
  endpoint  = var.email
}

# 文字列ERRORが含まれるログが出た場合、ErrorEventCountにカウントをする
resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  name           = "LambdaErrorCount"
  pattern        = "ERROR"
  log_group_name = "/aws/lambda/${aws_lambda_function.hello_go_function.function_name}"

  metric_transformation {
    name      = "ErrorEventCount"
    namespace = "ErrorMetrics"
    value     = "1"
  }
}
