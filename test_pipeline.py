import boto3
import json
import time
from datetime import datetime

def test_full_pipeline():
    # Test endpoint
    runtime = boto3.client('sagemaker-runtime')
    cloudwatch = boto3.client('cloudwatch')
    
    # Make prediction
    features = "1.0,2.0"
    response = runtime.invoke_endpoint(
        EndpointName='dev-lstm-endpoint',
        ContentType='text/csv',
        Body=features
    )
    prediction = float(response['Body'].read().decode().split('\n')[0])
    
    # Send metrics to CloudWatch
    cloudwatch.put_metric_data(
        Namespace='Healthcare/ML',
        MetricData=[
            {
                'MetricName': 'ModelAccuracy',
                'Value': 0.70,  
                'Unit': 'None',
                'Dimensions': [
                    {
                        'Name': 'ModelVersion',
                        'Value': 'v1'
                    }
                ]
            }
        ]
    )
    
    print("Pipeline test complete:")
    print(f"- Prediction: {prediction}")
    print(f"- Metrics sent to CloudWatch")
    print("Check CloudWatch alarms and GitHub Actions for triggered events")

if __name__ == "__main__":
    test_full_pipeline()