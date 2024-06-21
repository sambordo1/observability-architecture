// ----------------------------------------------------------------------------
// Use and existing key pair
// ----------------------------------------------------------------------------
resource "aws_key_pair" "existing_key" {
  key_name   = "observe-stack-key"
  public_key = file("~/.ssh/observe-stack-key.pem")
}

// ----------------------------------------------------------------------------
// Create EC2 instance 
// ----------------------------------------------------------------------------
resource "aws_instance" "observability_instance" {
  ami                  = "ami-04e5276ebb8451442"
  instance_type        = "t2.micro"
  key_name             = aws_key_pair.existing_key.key_name
  iam_instance_profile = aws_iam_instance_profile.cw_agent_instance_profile.name

  tags = {
    Project = "Observability"
  }

  user_data = file("install-observability.sh")
}
