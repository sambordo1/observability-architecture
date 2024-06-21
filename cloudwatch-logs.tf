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