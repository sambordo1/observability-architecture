# observability-architecture

## (1) Create an EC2 instance using Terraform

    - A Amazon Linux 2023 t2.micro EC2 instance named Observability
    - with the IAM role CloudWatchAgentServerPolicy
    - attached to a pre-existing key pair in my AWS account
    - with a user data script that creates systemd service, installs cloudwatch agent and starts everything up

## (2) Use EC2 user data to create a systemd service

    - Using a bash script to create a systemd service named observability.service
    - It performs these actions:
      - Creates service script
      - Makes the script executable
      - Creates logs directory
      - Creates systemd service file
      - Reloads systemd daemon to read new service
      - Enables and starts the service

## (3) Use EC2 user data to install the cloudwatch agent

    - Using a bash script to install the cloudwatch agent
    - It performs these actions:
      - Installs the cloudwatch agent
      - Creates cloudwatch config file
      - Starts the cloudwatch agent

## (4) Create Cloudwatch log stream using Terraform

    - Creates a Cloudwatch log group named /observability/ to match the cloudwatch config file
    - Creates a Cloudwatch log stream named logs to match the cloudwatch config file

## (5) Create Cloudwatch dashboard using Terraform

    - Display the logs in the Cloudwatch dashboard

## (6) Create Cloudwatch alarm using Terraform

    - Have the alarm go off when certain systemd logs are sent to Cloudwatch
    - The alarm will send notifications to an SNS topic ( a lambda function)

## (7) Create lambda function that sends message to Mattermost when logs are sent to Cloudwatch

    - Python lambda function
