import argparse
from typing import Dict, Any
from utils import setup_aws_clients, logger, log_metric

class EndpointHealthCheck:
    def __init__(self):
        self.clients = setup_aws_clients()
        
    def check_endpoint_metrics(self) -> Dict[str, Any]:
        """Check endpoint CloudWatch metrics."""
        try:
            response = self.clients['cloudwatch'].get_metric_data(
                MetricDataQueries=[
                    {
                        'Id': 'invocations',
                        'MetricStat': {
                            'Metric': {
                                'Namespace': 'AWS/SageMaker',
                                'MetricName': 'Invocations'
                            },
                            'Period': 300,
                            'Stat': 'Sum'
                        }
                    },
                    {
                        'Id': 'latency',
                        'MetricStat': {
                            'Metric': {
                                'Namespace': 'AWS/SageMaker',
                                'MetricName': 'ModelLatency'
                            },
                            'Period': 300,
                            'Stat': 'Average'
                        }
                    }
                ],
                StartTime='StartTime',
                EndTime='EndTime'
            )
            return response
            
        except Exception as e:
            logger.error(f"Error checking endpoint metrics: {e}")
            raise

    def run_health_check(self, check_type: str) -> bool:
        """Run comprehensive health check."""
        try:
            metrics = self.check_endpoint_metrics()
            
            # Define thresholds based on check type
            if check_type == 'pre-deployment':
                threshold = 0.95  # 95% success rate
            elif check_type == 'during-rollout':
                threshold = 0.98  # Higher threshold during rollout
            else:
                threshold = 0.99  # Highest for post-deployment
                
            # Calculate health score
            success_rate = metrics['success_rate']
            is_healthy = success_rate >= threshold
            
            # Log results
            log_metric("HealthCheckScore", 
                      success_rate,
                      dimensions=[{'Name': 'CheckType', 'Value': check_type}])
                      
            return is_healthy
            
        except Exception as e:
            logger.error(f"Health check failed: {e}")
            return False

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--check-type', 
                       choices=['pre-deployment', 'during-rollout', 'post-deployment'],
                       required=True)
    args = parser.parse_args()
    
    health_checker = EndpointHealthCheck()
    is_healthy = health_checker.run_health_check(args.check_type)
    
    if not is_healthy:
        raise Exception("Health check failed")

if __name__ == "__main__":
    main()