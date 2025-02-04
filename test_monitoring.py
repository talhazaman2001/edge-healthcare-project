import boto3
import json
import time

def test_model_monitoring():
    # Initialsse CloudWatch client
    cloudwatch = boto3.client('cloudwatch')
    
    # Send test metrics
    response = cloudwatch.put_metric_data(
        Namespace='Healthcare/ML',
        MetricData=[
            {
                'MetricName': 'ModelAccuracy',
                'Value': 0.70,  # This should trigger alarm if threshold is 0.95
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