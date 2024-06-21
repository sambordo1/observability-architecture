// ----------------------------------------------------------------------------
// Create IAM role for EC2 instance
// ----------------------------------------------------------------------------
resource "aws_iam_role" "cw_agent_role" {
  name = "CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

// ----------------------------------------------------------------------------
// Attach the CloudWatchAgentServerPolicy managed policy to the role
// ----------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "cw_agent_policy_attach" {
  role       = aws_iam_role.cw_agent_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

// ----------------------------------------------------------------------------
// Create the IAM instance profile
// ----------------------------------------------------------------------------
resource "aws_iam_instance_profile" "cw_agent_instance_profile" {
  name = "CloudWatchAgentInstanceProfile"
  role = aws_iam_role.cw_agent_role.name
}




