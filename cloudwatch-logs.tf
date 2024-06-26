// ----------------------------------------------------------------------------
// Create the Cloudwatch log group
// ----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "observability_log_group" {
  name              = "/observability/"
  retention_in_days = 7 # specify the retention period in days
}

// ----------------------------------------------------------------------------
// Create the Cloudwatch log stream
// ----------------------------------------------------------------------------
resource "aws_cloudwatch_log_stream" "observability_log_stream" {
  name           = "logs"
  log_group_name = aws_cloudwatch_log_group.observability_log_group.name
}

// ----------------------------------------------------------------------------
// Create the CloudWatch Dashboard
// ----------------------------------------------------------------------------
resource "aws_cloudwatch_dashboard" "observability_dashboard" {
  dashboard_name = "ObservabilityDashboard"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "log",
      "x": 0,
      "y": 0,
      "width": 24,
      "height": 6,
      "properties": {
        "query": "SOURCE '${aws_cloudwatch_log_group.observability_log_group.name}' | filter @logStream = '${aws_cloudwatch_log_stream.observability_log_stream.name}'",
        "region": "us-east-1",
        "stacked": false,
        "title": "Observability Service Logs"
      }
    }
  ]
}
EOF
}

// ----------------------------------------------------------------------------
// Create a Metric Filter for Log Stream Service
// ----------------------------------------------------------------------------
resource "aws_cloudwatch_log_metric_filter" "all_logs_metric_filter" {
  name           = "AllLogsMetricFilter"
  log_group_name = aws_cloudwatch_log_group.observability_log_group.name
  pattern        = "" // Empty pattern matches all log events

  metric_transformation {
    namespace     = "CustomLogMetrics"
    name          = "AllLogsCount"
    value         = "1"
    default_value = "0"
  }
}

// ----------------------------------------------------------------------------
// Create a CloudWatch Alarm for Service Logs
// ----------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "observability_service_alarm" {
  alarm_name                = "ObservabilityServiceAlarm"
  alarm_description         = "Observability Service is still running"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "AllLogsCount"
  namespace                 = "CustomLogMetrics"
  period                    = 300
  statistic                 = "Sum"
  threshold                 = 1
  actions_enabled           = true
  alarm_actions             = [aws_sns_topic.log_notification_topic.arn, aws_lambda_function.lambda_notifier.arn]
  ok_actions                = []
  insufficient_data_actions = []
  treat_missing_data        = "notBreaching"
}


// ----------------------------------------------------------------------------
// Create SNS Topic for Stopped Service
// ----------------------------------------------------------------------------
resource "aws_sns_topic" "log_notification_topic" {
  name = "log-notification-topic"
}

// ----------------------------------------------------------------------------
// Create SNS Topic Subscription
// ----------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "log_notification_email_subscription" {
  topic_arn = aws_sns_topic.log_notification_topic.arn
  protocol  = "email"
  endpoint  = "sambordo1@gmail.com"
}
