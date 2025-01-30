from utils import setup_aws_clients, logger, log_metric

class ModelRollback:
    def __init__(self):
        self.clients = setup_aws_clients()
        
    def perform_rollback(self) -> None:
        """Rollback to previous model version."""
        try:
            # Get previous endpoint configuration
            previous_config = self.clients['sagemaker'].describe_endpoint_config(
                EndpointConfigName='previous-config'
            )
            
            # Update endpoint to use previous configuration
            self.clients['sagemaker'].update_endpoint(
                EndpointName='endpoint-name',
                EndpointConfigName='previous-config'
            )
            
            log_metric("RollbackExecuted", 
                      1,
                      dimensions=[{'Name': 'Endpoint', 'Value': 'endpoint-name'}])
                      
            logger.info("Rollback completed successfully")
            
        except Exception as e:
            logger.error(f"Rollback failed: {e}")
            log_metric("RollbackFailed", 1)
            raise

def main():
    rollback = ModelRollback()
    rollback.perform_rollback()

if __name__ == "__main__":
    main()