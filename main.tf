# billing
variable "billing_name" {
    default = "Atom is running out of money"
}

variable "billing_threshold" {
    default = [
        1,
        5,
        10,
    ]
}

resource "aws_sns_topic" "billing" {
    name = "BillingAlarm"
}

resource "aws_cloudwatch_metric_alarm" "billing" {
    alarm_name = "${var.billing_name} lv.${count.index + 1} (${var.billing_threshold[count.index]} USD)"
    namespace = "AWS/Billing"
    metric_name = "EstimatedCharges"
    statistic = "Maximum"
    evaluation_periods = "1"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    period = "21600"
    threshold = "${var.billing_threshold[count.index]}"
    alarm_description= "Total Charge ${var.billing_threshold[count.index]} USD"
    alarm_actions = [ "${aws_sns_topic.billing.arn}" ]
    count = "${length(var.billing_threshold)}"

    dimensions = {
        currency = "USD"
    }
}
