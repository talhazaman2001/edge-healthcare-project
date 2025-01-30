import argparse
from utils import setup_aws_clients, logger, log_metric

class ModelRollout:
    def __init__(self):
        self.clients = setup_aws_clients()
        
    def update_endpoint_weights(self, percentage: int) -> None:
        """Update traffic distribution for endpoint."""
        try:
            endpoint_config = self.clients['sagemaker'].describe_endpoint_config(
                EndpointConfigName='current-config'
            )
            
            # Calculate weights
            new_weight = percentage / 100.0
            old_weight = 1 - new_weight
            
            # Update variant weights
            variants = endpoint_config['ProductionVariants']
            variants[0]['VariantWeight'] = old_weight  # Old model
            variants[1]['VariantWeight'] = new_weight  # New model
            
            # Create new config
            self.clients['sagemaker'].create_endpoint_config(
                EndpointConfigName=f"config-{percentage}percent",
                ProductionVariants=variants
            )
            
            # Update endpoint
            self.clients['sagemaker'].update_endpoint(
                EndpointName='endpoint-name',
                EndpointConfigName=f"config-{percentage}percent"
            )
            
            log_metric("RolloutPercentage", 
                      percentage,
                      dimensions=[{'Name': 'Endpoint', 'Value': 'endpoint-name'}])
                      
        except Exception as e:
            logger.error(f"Error updating endpoint weights: {e}")
            raise

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--percentage', type=int, required=True)
    args = parser.parse_args()
    
    rollout = ModelRollout()
    rollout.update_endpoint_weights(args.percentage)

if __name__ == "__main__":
    main()