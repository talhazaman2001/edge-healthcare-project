import os
import time
from typing import Dict, Any 
from utils import setup_aws_clients, logger, log_metric

def monitor_training_job() -> Dict[str, Any]:
    """Monitor SageMaker training job progress."""
    clients = setup_aws_clients()
    job_name = os.environ['TRAINING_JOB_NAME']
    logger.info(f"Monitoring training job: {job_name}")

    while True: 
        try:
            response = clients['sagemaker'].describe_training_job(
                TrainingJobName = job_name
            )
            status = response['TrainingJobStatus']
            logger.info(f"Current status: {status}")

            # Log metrics
            log_metric("TrainingJobStatus",
                       1 if status == 'Completed' else 0,
                       dimensions = [{'Name': 'JobName', 'Value': job_name}])
            
            if status == 'Completed':
                logger.info("Training completed successfully")
                model_artifact = response['ModelArtifacts']['S3ModelArtifacts']
                
                with open(os.environ['GITHUB_OUTPUT'], 'a') as f:
                    f.write(f"model_name={job_name}-model\n")
                    return response 
                
            elif status in ['Failed', 'Stopped']:
                raise Exception(f"Training job {status}")
            
            time.sleep(60)

        except Exception as e: 
            logger.error(f"Error monitoring training job: {e}")
            log_metric("TrainingJobError", 1)
            raise 
if __name__ == "__main__":
    monitor_training_job()
