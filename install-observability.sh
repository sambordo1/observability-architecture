#!/bin/bash

# Create a new user for running the service, or ensure the user exists
if ! id "observability_user" &>/dev/null; then
    sudo useradd -m -s /bin/bash observability_user
    echo "User observability_user created."
else
    echo "User observability_user already exists."
fi

# Create the service script
cat << 'EOF' > /usr/local/bin/system-script.sh
#!/bin/bash
# This script continuously checks the status of observability.service
while true; do
  # Output the current status to a log file
  systemctl status observability.service > /var/log/observability/logs.log
  # Sleep for an hour before repeating the process
  sleep 3600
done
EOF

# Make the script executable
sudo chmod +x /usr/local/bin/system-script.sh

# Ensure the log directory exists and set permissions
sudo mkdir -p /var/log/observability
sudo chown observability_user:observability_user /var/log/observability
sudo chmod 755 /var/log/observability

# Create the systemd service file
cat << 'EOF' > /etc/systemd/system/observability.service
[Unit]
Description=Service to monitor the status of observability.service

[Service]
User=observability_user
ExecStart=/usr/local/bin/system-script.sh
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Set permissions for the service file
sudo chown root:root /etc/systemd/system/observability.service
sudo chmod 644 /etc/systemd/system/observability.service

# Reload systemd to recognize the new or changed unit file
sudo systemctl daemon-reload

# Enable the service to start at boot
sudo systemctl enable observability.service

# Start the service immediately
sudo systemctl start observability.service

echo "Service setup complete. Observability service is now running under non-root user: observability_user."

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
