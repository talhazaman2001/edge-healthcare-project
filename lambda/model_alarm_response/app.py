import json
import boto3
import logging
from typing import Dict, Any
import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

sagemaker = boto3.client('sagemaker')
sns = boto3.client('sns')

class ModelMonitoringResponse:
    def __init__(self, event: Dict[str, Any]):
        self.event = event
        self.alarm_name = event['detail']['alarmName']
        self.alarm_description = event['detail'].get('alarmDescription', '')
        self.trigger = event['detail']['configuration']['metrics'][0]

    def handle_accuracy_drop(self):
        """Handle model accuracy dropping below threshold."""
        logger.info(f"Handling accuracy drop for alarm: {self.alarm_name}")

        try:
            # Get current endpoint configuration
            endpoint_name = self.event['detail']['configuration'].get('dimensions', {}).get('EndpointName')

            if self.trigger['value'] < 0.8:
                self._switch_to_backup_model(endpoint_name)

            # Trigger model retraining
            self._trigger_retraining_pipeline()

            # Send high-priority alert
            self._send_alert(
                subject = "CRITICAL: Model Accuracy Drop Detected",
                message = f"Model accuracy has dropped to {self.trigger['value']}."
                          f"Automatic Response actions have been initiated."
            )

        except Exception as e:
            logger.error(f"Error handling accuracy drop: {e}")
            self._send_alert(
                subject = "ERROR: Failed to handle accuracy drop",
                message = f"Error: {str(e)}"
            )

    def handle_high_latency(self):
        """Handle high prediction latency."""
        logger.info(f"Handling high latency for alarm: {self.alarm_name}")

        try: 
            endpoint_name = self.event['detail']['configuration'].get('dimensions', {}).get('EndpointName')

            # Scale up endpoint
            response = sagemaker.update_endpoint_config(
                EndpointConfigName = f"{endpoint_name}-config",
                InstanceCount = 2
            )

            self._send_alert(
                subject = "WARNING: High Latency Detected",
                message = f"High prediction latency detected. Scaling up endpoint {endpoint_name}."
            )

        except Exception as e:
            logger.error(f"Error handling high latency: {e}")
            self._send_alert(
                subject = "ERROR: Failed to handle high latency",
                message = f"Error: {str(e)}"
            )

    def handle_data_drift(self):
        """Handle detected data drift."""
        logger.info(f"Handling data drift for alarm: {self.alarm_name}")
        
        try:
            # Capture current distribution
            drift_value = self.trigger['value']
            
            if drift_value > 0.3:  # Significant drift
                # Trigger retraining pipeline
                self._trigger_retraining_pipeline()
                
                self._send_alert(
                    subject="WARNING: Significant Data Drift Detected",
                    message=f"Data drift value: {drift_value}. Initiating model retraining."
                )
            else:
                self._send_alert(
                    subject="INFO: Minor Data Drift Detected",
                    message=f"Data drift value: {drift_value}. Monitoring situation."
                )
                
        except Exception as e:
            logger.error(f"Error handling data drift: {e}")
            self._send_alert(
                subject="ERROR: Failed to handle data drift",
                message=f"Error: {str(e)}"
            )

    def _switch_to_backup_model(self, endpoint_name: str):
        """Switch endpoint to backup model."""
        try:
            response = sagemaker.update_endpoint(
                EndpointName=endpoint_name,
                EndpointConfigName=f"{endpoint_name}-backup-config"
            )
            logger.info(f"Switched to backup model for endpoint: {endpoint_name}")
        except Exception as e:
            logger.error(f"Error switching to backup model: {e}")
            raise

    def _trigger_retraining_pipeline(self):
        """Trigger model retraining via GitHub Actions."""
        try:
            # Create GitHub client
            github = boto3.client('secretsmanager')
            
            # Get GitHub token from AWS Secrets Manager
            github_token = github.get_secret_value(
                SecretId='github-actions-token'
            )['SecretString']

            # Define repository details
            repo = "edge-healthcare project"
            owner = "talhazaman2001"
            
            # Trigger GitHub workflow
            import requests
            response = requests.post(
                f'https://api.github.com/repos/{owner}/{repo}/dispatches',
                headers={
                    'Authorization': f'token {github_token}',
                    'Accept': 'application/vnd.github.v3+json'
                },
                json={
                    'event_type': 'retrain_model',
                    'client_payload': {
                        'triggered_by': 'monitoring_alarm',
                        'timestamp': str(datetime.now()),
                        'metrics': self.trigger
                    }
                }
            )
            
            if response.status_code == 204:
                logger.info("Successfully triggered GitHub Actions workflow")
            else:
                logger.error(f"Failed to trigger workflow: {response.status_code}")
                
        except Exception as e:
            logger.error(f"Error triggering GitHub Actions workflow: {e}")
            raise

    def _send_alert(self, subject: str, message: str):
        """Send SNS alert."""
        try:
            sns.publish(
                TopicArn='your-sns-topic-arn',  # Replace with your SNS topic
                Subject =subject,
                Message =message
            )
        except Exception as e:
            logger.error(f"Error sending alert: {e}")
            raise

def handler(event, context):
    """Lambda handler for alarm response."""
    try:
        logger.info(f"Received alarm event: {json.dumps(event)}")
        
        response_handler = ModelMonitoringResponse(event)
        alarm_name = event['detail']['alarmName'].lower()
        
        if "accuracy" in alarm_name:
            response_handler.handle_accuracy_drop()
        elif "latency" in alarm_name:
            response_handler.handle_high_latency()
        elif "drift" in alarm_name:
            response_handler.handle_data_drift()
        else:
            logger.warning(f"Unknown alarm type: {alarm_name}")
            
        return {
            'statusCode': 200,
            'body': json.dumps('Alarm handled successfully')
        }
        
    except Exception as e:
        logger.error(f"Error handling alarm: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error handling alarm: {str(e)}')
        }       
    
