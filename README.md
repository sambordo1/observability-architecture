# observability-architecture

The goal of this project is to use Infrastructure as Code (Terraform) to:

(1) create an EC2 instance
    - give it the IAM role CloudWatchAgentServerPolicy
(2) Use EC2 user data to:
    - create a systemd service
    - install the cloudwatch agent
    - create cloudwatch config file
(3) create Cloudwatch log stream to catch log events

## (1) Create an EC2 instance using Terraform


