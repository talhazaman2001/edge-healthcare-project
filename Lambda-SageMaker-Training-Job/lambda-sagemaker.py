import boto3
import json
import os

# Initialise SageMaker Client
sagemaker = boto3.client('sagemaker')

# Define the training job parameters
training_job_name = "train-model"
role_arn = os.environ['SAGEMAKER_ROLE_ARN']
s3_input_uri = "s3://historical-sagemaker-bucket-talha/historical-training-data/"
s3_output_uri = "s3://historical-sagemaker-bucket-talha/historical-model-output/"

# Define the training job configuration
training_params = {
    "TrainingJobName" : training_job_name,
    "AlgorithmSpecification" : {
        "TrainingImage" : "763104351884.dkr.ecr.eu-west-2.amazonaws.com/tensorflow-training:2.3.0-gpu-py37-cu110-ubuntu18.04",
        "TrainingInputMode" : "File"
    },
    "RoleArn" : role_arn,
    "InputDataConfig" : [
        {
            "ChannelName" : "train",
            "DataSource" : {
                "S3DataSource" : {
                    "S3Uri" : s3_input_uri,
                    "S3DataType" : "S3Prefix",
                    "S3DataDistributionType" : "FullyReplicated"
                }
            }
        }
    ],
    "OutputDataConfig" : {
        "S3OutputPath" : s3_output_uri
    },
    "ResourceConfig" : {
        "InstancType" : "mk.p2.xlarge",
        "InstanceCount" : 1,
        "VolumeSizeInGB" : 50
    },
    "StoppingCondition" : {
        "MaxRuntimeInSeconds" : 86400
    },
    "Hyperparameters" : {
        "epochs" : "50",
        "batch_size" : "64",
        "learning_rate" : "0.001",
        "model_type" : "lstm"
    }
}

# Start the SageMaker training job
def trigger_training_job():
    try:
        response = sagemaker.create_training_job(**training_params)
        print(f"Training job {training_job_name} started successfully.")
        print(json.dumps(response, indent = 4, default = str))
    
    except Exception as e:
        print(f"Error starting training job: {str(e)}")
