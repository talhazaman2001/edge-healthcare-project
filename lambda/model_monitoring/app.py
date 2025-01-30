import json
import boto3
import time
import numpy as np
from datetime import datetime
from typing import Dict, Any, Tuple, List, Union
import logging
from botocore.exceptions import ClientError

# Set up logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Initialise AWS Clients with error handling
def get_aws_client(service_name: str):
    try:
        return boto3.client(service_name)
    except Exception as e:
        logger.error(f"Failed to initialise {service_name} client: {e}")
        raise

def get_aws_resource(service_name: str):
    try:
        return boto3.resource(service_name)
    except Exception as e:
        logger.error(f"Failed to initialise {service_name} resource: {e}")
        raise

# Initialise AWS clients
try:
    dynamodb = get_aws_resource('dynamodb')
    cloudwatch = get_aws_client('cloudwatch')
    table = dynamodb.Table('model-metrics')
except Exception as e:
    logger.error(f"Failed to initialise AWS services: {e}")
    raise

def calculate_accuracy(predictions: List[float], actuals: List[float]) -> float:
    """
    Calculate model accuracy with input validation.
    
    Args:
        predictions: List of model predictions
        actuals: List of actual values
        
    Returns:
        float: Accuracy score between 0 and 1
    """
    try:
        if not predictions or not actuals:
            logger.warning("Empty predictions or actuals list")
            return 0.0
            
        if len(predictions) != len(actuals):
            logger.error("Predictions and actuals lists have different lengths")
            return 0.0
            
        correct = sum(1 for p, a in zip(predictions, actuals) if p == a)
        return correct / len(predictions)
    except Exception as e:
        logger.error(f"Error calculating accuracy: {e}")
        return 0.0

def calculate_drift(current_data: np.array, baseline_data: np.array) -> float:
    """
    Calculate data drift using KL divergence with enhanced error handling.
    
    Args:
        current_data: numpy array of current data
        baseline_data: numpy array of baseline data
        
    Returns:
        float: KL divergence score
    """
    try:
        # Input validation
        if len(current_data) == 0 or len(baseline_data) == 0:
            logger.warning("Empty data arrays provided for drift calculation")
            return 0.0

        # Normalise data
        current_dist, _ = np.histogram(current_data, bins=20, density=True)
        baseline_dist, _ = np.histogram(baseline_data, bins=20, density=True)
        
        # small epsilon to avoid division by zero
        epsilon = 1e-10
        current_dist = current_dist + epsilon
        baseline_dist = baseline_dist + epsilon
        
        # Calculate KL divergence
        kl_div = np.sum(current_dist * np.log(current_dist / baseline_dist))
        
        # Log drift value for monitoring
        logger.info(f"Calculated drift value: {kl_div}")
        return float(kl_div)
        
    except Exception as e:
        logger.error(f"Error calculating drift: {str(e)}", exc_info=True)
        return 0.0

def measure_latency(start_time: float) -> float:
    """
    Calculate prediction latency in milliseconds.
    
    Args:
        start_time: Start timestamp
        
    Returns:
        float: Latency in milliseconds
    """
    try:
        latency = (time.time() - start_time) * 1000  # Convert to milliseconds
        return round(latency, 2)
    except Exception as e:
        logger.error(f"Error measuring latency: {e}")
        return 0.0

def store_metrics(metrics: Dict[str, Any], model_version: str) -> bool:
    """
    Store metrics in DynamoDB and CloudWatch with enhanced error handling.
    
    Args:
        metrics: Dictionary of metrics to store
        model_version: Version identifier of the model
        
    Returns:
        bool: Success status
    """
    timestamp = int(time.time())
    success = True

    # Store in DynamoDB
    try:
        table.put_item(
            Item={
                'ModelVersion': model_version,
                'Timestamp': timestamp,
                'Metrics': metrics,
                'CreatedAt': datetime.utcnow().isoformat()
            }
        )
        logger.info(f"Successfully stored metrics in DynamoDB for model version {model_version}")
    except ClientError as e:
        logger.error(f"DynamoDB ClientError: {e.response['Error']['Message']}")
        success = False
    except Exception as e:
        logger.error(f"Error storing metrics in DynamoDB: {e}")
        success = False

    # Send to CloudWatch
    try:
        cloudwatch.put_metric_data(
            Namespace='Healthcare/ML',
            MetricData=[
                {
                    'MetricName': metric_name,
                    'Value': value,
                    'Unit': 'None' if metric_name != 'PredictionLatency' else 'Milliseconds',
                    'Timestamp': datetime.fromtimestamp(timestamp),
                    'Dimensions': [
                        {'Name': 'ModelVersion', 'Value': model_version},
                        {'Name': 'Environment', 'Value': 'production'}
                    ]
                }
                for metric_name, value in {
                    'ModelAccuracy': metrics['accuracy'],
                    'PredictionLatency': metrics['latency'],
                    'DataDrift': metrics['drift']
                }.items()
            ]
        )
        logger.info(f"Successfully sent metrics to CloudWatch for model version {model_version}")
    except ClientError as e:
        logger.error(f"CloudWatch ClientError: {e.response['Error']['Message']}")
        success = False
    except Exception as e:
        logger.error(f"Error sending metrics to CloudWatch: {e}")
        success = False

    return success

def validate_input(event: Dict) -> Tuple[bool, str]:
    """
    Validate input event data.
    
    Args:
        event: Lambda event dictionary
        
    Returns:
        Tuple[bool, str]: Validation status and error message
    """
    required_fields = ['predictions', 'actuals', 'current_data', 'baseline_data', 
                      'model_version', 'start_time']
    
    for field in required_fields:
        if field not in event:
            return False, f"Missing required field: {field}"
            
    if not isinstance(event['predictions'], list) or not isinstance(event['actuals'], list):
        return False, "Predictions and actuals must be lists"
        
    return True, ""

def handler(event: Dict, context: Any) -> Dict:
    """
    Lambda handler for model monitoring with enhanced error handling and logging.
    
    Args:
        event: Lambda event dictionary
        context: Lambda context object
        
    Returns:
        Dict: Response dictionary
    """
    logger.info(f"Processing monitoring event for model")
    
    try:
        # Validate input
        is_valid, error_message = validate_input(event)
        if not is_valid:
            logger.error(f"Input validation failed: {error_message}")
            return {
                'statusCode': 400,
                'body': json.dumps({'error': error_message})
            }

        # Extract and log event data
        predictions = event['predictions']
        actuals = event['actuals']
        current_data = np.array(event['current_data'])
        baseline_data = np.array(event['baseline_data'])
        model_version = event['model_version']
        start_time = event['start_time']

        logger.info(f"Processing metrics for model version: {model_version}")

        # Calculate metrics
        metrics = {
            'accuracy': calculate_accuracy(predictions, actuals),
            'latency': measure_latency(start_time),
            'drift': calculate_drift(current_data, baseline_data),
            'timestamp': int(time.time())
        }

        logger.info(f"Calculated metrics: {metrics}")

        # Store metrics
        success = store_metrics(metrics, model_version)

        return {
            'statusCode': 200 if success else 500,
            'body': json.dumps({
                'metrics': metrics,
                'success': success
            })
        }

    except Exception as e:
        logger.error(f"Unexpected error in handler: {str(e)}", exc_info=True)
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'type': str(type(e).__name__)
            })
        }