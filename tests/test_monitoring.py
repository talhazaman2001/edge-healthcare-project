import boto3
import time
from datetime import datetime
from decimal import Decimal 

def test_model_monitoring():
    dynamodb = boto3.resource('dynamodb')
    cloudwatch = boto3.client('cloudwatch')
    table = dynamodb.Table('dev-model-metrics')

    # Store metric in DynamoDB
    metric_data = {
        'ModelVersion': 'v1',
        'Timestamp': int(time.time()),
        'MetricType': 'Accuracy',
        'Value': Decimal(str(0.50)),
        'Environment': 'dev'
    }

    # Store in DynamoDB
    table.put_item(Item=metric_data)
    print("Metric stored in DynamoDB")
    
    # Send test metrics
    response = cloudwatch.put_metric_data(
        Namespace='Healthcare/ML',
        MetricData=[
            {
                'MetricName': 'ModelAccuracy',
                'Value': 0.70, 
                'Unit': 'None',
                'Dimensions': [{
                    'Name': 'Environment',
                    'Value': 'dev'
                }]
            }
        ]
    )
    print(f"Metrics sent: {response}")

    # Wait a moment for metrics to appear
    time.sleep(5)

    # verify metrics
    response = cloudwatch.get_metric_data(
        MetricDataQueries=[
            {
                'Id': 'm1',
                'MetricStat': {
                    'Metric': {
                        'Namespace': 'Healthcare/ML',
                        'MetricName': 'ModelAccuracy',
                        'Dimensions': [{
                            'Name': 'Environment',
                            'Value': 'dev'
                        }]
                    },
                    'Period': 60,
                    'Stat': 'Average'
                }
            }
        ],
        StartTime = time.time() - 300,
        EndTime = time.time()
    )
    print(f"Metrics verification: {response}")

if __name__ == "__main__":
    test_model_monitoring()