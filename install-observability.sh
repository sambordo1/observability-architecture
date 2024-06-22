#!/bin/bash

# Create the service script
cat << 'EOL' > /usr/local/bin/system-script.sh
#!/bin/bash
while true; do
  systemctl status observability.service | grep "Active:" | sudo tee -a /var/log/observability/logs.log > /dev/null
  sleep 3600
done
EOL

# Make the script executable
sudo chmod +x /usr/local/bin/system-script.sh

# Create the logs directory
sudo mkdir -p /var/log/observability

# Set ownership and permissions for the directory
sudo chown ec2-user:ec2-user /var/log/observability
sudo chmod 755 /var/log/observability

# Create the systemd service file
cat << 'EOL' > /etc/systemd/system/observability.service
[Unit]
Description=Experimenting with systemd observability

[Service]
User=ec2-user
WorkingDirectory=/etc/systemd/system
ExecStart=/usr/local/bin/system-script.sh
Restart=always
RestartSec=3
StandardOutput=file:/var/log/observability/logs.log
StandardError=file:/var/log/observability/logs.log

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd to read the new service
sudo systemctl daemon-reload

# Enable the service to start at boot
sudo systemctl enable observability.service

# Start the service immediately
sudo systemctl start observability.service

# Install CloudWatch Agent
sudo yum install -y amazon-cloudwatch-agent

# Create CloudWatch Agent configuration file
sudo mkdir -p /home/ec2-user/cloudwatch
cat << 'EOL' > /home/ec2-user/cloudwatch/config.json
{
    "agent": {
        "metrics_collection_interval": 60,
        "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/observability/logs.log",
                        "log_group_name": "/observability/",
                        "log_stream_name": "logs",
                        "timezone": "UTC"
                    }
                ]
            }
        },
        "log_stream_name": "logs",
        "force_flush_interval": 60
    }
}
EOL

# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/home/ec2-user/cloudwatch/config.json -s
