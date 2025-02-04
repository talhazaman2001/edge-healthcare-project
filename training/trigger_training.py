import os 
import json 
from datetime import datetime, timezone
from utils import setup_aws_clients, logger, log_metric

def trigger_training_job():
    """Start SageMaker training job with configuration."""
    try: 
        clients = setup_aws_clients()
        timestamp = int(datetime.now(timezone.utc).timestamp())
        job_name = f"healtchare-lstm-{timestamp}"

        training_params = {
            "TrainingJobName": job_name,
            "AlgorithmSpecification": {
                "TrainingImage": "764974769150.dkr.ecr.eu-west-2.amazonaws.com/sagemaker-xgboost:1.7-1",
                "TrainingInputMode": "File"
            },
            "RoleArn": os.environ['SAGEMAKER_ROLE_ARN'],
            "InputDataConfig": [{
                "ChannelName": "training",
                "DataSource": {
                    "S3DataSource": {
                        "S3DataType": "S3Prefix",
                        "S3Uri": f"s3://{os.environ['MODEL_BUCKET']}/historical-training-data/",
                        "S3DataDistributionType": "FullyReplicated"
                    }
                }
            }],
            "OutputDataConfig": {
                "S3OutputPath": f"s3://{os.environ['MODEL_BUCKET']}/trained-models/"
            },
            "ResourceConfig": {
                "InstanceType": "ml.m5.large",
                "InstanceCount": 1,
                "VolumeSizeInGB": 50
            },
            "StoppingCondition": {
                "MaxRuntimeInSeconds": 86400
            },
            "HyperParameters": {
                "epochs": "50",
                "batch_size": "64",
                "learning_rate": "0.001",
                "model_type": "lstm"
            }
        }

        response = clients['sagemaker'].create_training_job(**training_params)
        logger.info(f"Started training job: {job_name}")
        log_metric("TrainingJobStarted", 1)

        # Set output for GitHub Actions
        with open(os.environ['GITHUB_OUTPUT'], 'a') as f: 
            f.write(f"job_name={job_name}\n")

        return job_name
    
    except Exception as e:
        logger.error(f"Failed to start training job: {e}")
        log_metric("TrainigJobFailed", 1)
        raise 

if __name__ == "__main__":
    trigger_training_job()