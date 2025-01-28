import json
import boto3
import time
import numpy as np
from datetime import datetime
from typing import Dict, Any, Tuple

# Initialise AWS Clients
dynamodb = boto3.resource('dynamodb')
cloudwatch = boto3.client('cloudwatch')
table = dynamodb.Table('model-metrics')

def calculate_accuracy(predictions: list, actuals: list) -> float:
    """Calculate model accuracy."""
    correct = sum(1 for p, a in zip(predictions, actuals) if p == a)
    return correct / len(predictions) if predictions else 0

def calculate_drift(current_data: np.array, baseline_data: np.array) -> float:
    """Calculate data drift using KL divergence."""
    try: 
        current_dist = np.histogram(current_data, bins = 20, density = True)[0]
        baseline_dist = np.histogram(baseline_data, bins = 20, denisty = True)[0]

        epsilon = 1e-10
        current_dist = current_dist + epsilon 
        baseline_dist = baseline_dist + epsilon 

        kl_div = np.sum(current_dist * np.log(current_dist / baseline_dist))
        return float(kl_div)
    
    except Exception as e: 
        print(f"Error calculating drift: {e}")
        return 0.0 
    
def measure_latency(start_time: float) -> float: 
    """Calculate prediction latency."""
    return time.time() - start_time

def store_metrics(metrics: Dict[str, Any], model_version:str):
    """Store metrics in DynamoDB and CloudWatch."""
    timestamp = int(time.time())

    # Store in DynamoDB
    try:
        table.put_item(
            Item={
                'ModelVersion': model_version,
                'Timestamp': timestamp,
                'Metrics': metrics
            }
        )
    except Exception as e:
        print(f"Error storing metrics in DynamoDB: {e}")

    # Send to CloudWatch
    try:
        cloudwatch.put_metric_data(
            Namespace='Healthcare/ML',
            MetricData=[
                {
                    'MetricName': 'ModelAccuracy',
                    'Value': metrics['accuracy'],
                    'Unit': 'None',
                    'Timestamp': datetime.fromtimestamp(timestamp),
                    'Dimensions': [
                        {'Name': 'ModelVersion', 'Value': model_version}
                    ]
                },
                {
                    'MetricName': 'PredictionLatency',
                    'Value': metrics['latency'],
                    'Unit': 'Milliseconds',
                    'Timestamp': datetime.fromtimestamp(timestamp),
                    'Dimensions': [
                        {'Name': 'ModelVersion', 'Value': model_version}
                    ]
                },
                {
                    'MetricName': 'DataDrift',
                    'Value': metrics['drift'],
                    'Unit': 'None',
                    'Timestamp': datetime.fromtimestamp(timestamp),
                    'Dimensions': [
                        {'Name': 'ModelVersion', 'Value': model_version}
                    ]
                }
            ]
        )
    except Exception as e:
        print(f"Error sending metrics to CloudWatch: {e}")

def handler(event, context):
    """Lambda handler for model monitoring."""
    try: 
        # Extract data from event
        predictions = event['predictions']
        actuals = event['actuals']
        current_data = event['current_data']
        baseline_data = event['baseline_data']
        model_version = event['model_version']
        start_time = event['start_time']

        # Calculate metrics
        metrics = {
            'accuracy': calculate_accuracy(predictions, actuals),
            'latency': measure_latency(start_time),
            'drift': calculate_drift(current_data, baseline_data),
            'timestamp': int(time.time())
        }

        # Store metrics
        store_metrics(metrics, model_version)

        return {
            'statusCode': 200,
            'body': json.dumps(metrics)
        }

    except Exception as e:
        print(f"Error processing metrics: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }