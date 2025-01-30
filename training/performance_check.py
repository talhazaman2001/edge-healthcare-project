from utils import setup_aws_clients, logger, log_metric

class ModelPerformanceCheck:
    def __init__(self):
        self.clients = setup_aws_clients()
        
    def validate_performance(self) -> bool:
        """Validate model performance metrics."""
        try:
            # Get model metrics
            metrics = self.clients['cloudwatch'].get_metric_data(
                MetricDataQueries=[
                    {
                        'Id': 'accuracy',
                        'MetricStat': {
                            'Metric': {
                                'Namespace': 'MLOps/ModelMetrics',
                                'MetricName': 'ModelAccuracy'
                            },
                            'Period': 300,
                            'Stat': 'Average'
                        }
                    }
                ],
                StartTime='StartTime',
                EndTime='EndTime'
            )
            
            # Define performance thresholds
            accuracy_threshold = 0.95
            latency_threshold = 100  # ms
            
            # Check if performance meets thresholds
            meets_threshold = (
                metrics['accuracy'] >= accuracy_threshold and
                metrics['latency'] <= latency_threshold
            )
            
            log_metric("PerformanceValidation", 
                      1 if meets_threshold else 0)
                      
            return meets_threshold
            
        except Exception as e:
            logger.error(f"Performance validation failed: {e}")
            log_metric("PerformanceValidationError", 1)
            raise

def main():
    checker = ModelPerformanceCheck()
    if not checker.validate_performance():
        raise Exception("Performance validation failed")

if __name__ == "__main__":
    main()