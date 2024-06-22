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