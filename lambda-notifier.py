import json
import requests

def lambda_handler(event, context):
    # Extract information from the CloudWatch alarm event
    alarm_name = event['alarmData']['alarmName']
    state = event['alarmData']['state']['value']
    reason = event['alarmData']['state']['reason']
    
    # Only send a notification if the state is ALARM
    if state == "ALARM":
        url = 'https://chat.company.com/api/v4/posts'
        channel_id = 'xxxxxxxxxxxxxxxxxxxxxxxx'
        message = f'CloudWatch Alarm: {alarm_name} is in ALARM state. Reason: {reason}'
        token = 'XXxXXXXXXXXXXXXXXXXXXXXXXXXXXX'  # Replace with your actual token

        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json"
        }

        data = {
            "channel_id": channel_id,
            "message": message,
            "root_id": None,
            "props": {}
        }

        response = requests.post(url, headers=headers, json=data)

        return {
            'statusCode': response.status_code,
            'body': response.text
        }
    
    return {
        'statusCode': 200,
        'body': 'No action required, alarm state is not ALARM'
    }