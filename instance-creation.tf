// ----------------------------------------------------------------------------
// Use and existing key pair
// ----------------------------------------------------------------------------
data "aws_key_pair" "existing_key" {
  key_name = "observe-stack-key"
}

// ----------------------------------------------------------------------------
// Create EC2 instance 
// ----------------------------------------------------------------------------
resource "aws_instance" "observability_instance" {
  name                 = "observability"
  ami                  = "ami-04e5276ebb8451442"
  instance_type        = "t2.micro"
  key_name             = data.aws_key_pair.existing_key.key_name
  iam_instance_profile = aws_iam_instance_profile.cw_agent_instance_profile.name

  tags = {
    Project = "Observability"
  }

  user_data = file("install-observability.sh")
}
