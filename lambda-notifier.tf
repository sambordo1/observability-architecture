// ----------------------------------------------------------------------------
// Create lambda function in terrafrom using packaged python function
// ----------------------------------------------------------------------------
resource "aws_lambda_function" "lambda_notifier" {
  function_name = "LambdaNotifier"
  handler       = "lambda-notifier.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  runtime       = "python3.11"

  filename         = "lambda_package/function.zip"
  source_code_hash = filebase64sha256("lambda_package/function.zip")

  environment {
    variables = {
      EXAMPLE_VARIABLE = "example_value"
    }
  }
}

// ----------------------------------------------------------------------------
// Create  IAM Role for Lambda Execution
// ----------------------------------------------------------------------------
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Effect = "Allow",
        Sid    = ""
      },
    ]
  })
}

// ----------------------------------------------------------------------------
// Create IAM Policy for Lambda Execution Role
// ----------------------------------------------------------------------------
resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_policy"
  role = aws_iam_role.lambda_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*",
        Effect   = "Allow"
      },
    ]
  })
}

// ----------------------------------------------------------------------------
// Create Lambda Permission to Allow Cloudwatch to Invoke Lambda
// ----------------------------------------------------------------------------
# Lambda Permission to Allow CloudWatch to Invoke Lambda
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke_lambda" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_notifier.function_name
  principal     = "lambda.alarms.cloudwatch.amazonaws.com"
  source_arn    = aws_cloudwatch_metric_alarm.observability_service_alarm.arn
}