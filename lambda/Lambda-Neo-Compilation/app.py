import boto3
import json
import os

# Initialise SageMaker Client
sagemaker = boto3.client('sagemaker')

# Define the training job parameters
compilation_job_name = "lstm-neo-model"
role_arn = os.environ['SAGEMAKER_ROLE_ARN']
s3_model_uri = "s3://historical-sagemaker-bucket-talha/trained-models/model.tar.gz"
s3_output_uri = "s3://historical-sagemaker-bucket-talha/neo-compilation-output/"

# Define the compilation job configuration
compilation_params = {
    "CompilationJobName" : compilation_job_name,
    "RoleArn" : role_arn,
    "InputConfig" : {
        "S3Uri" : s3_model_uri,
        "DataInputConfig" : "{\"input\": [1, 224, 224, 31]}",
        "Framework" : "greengrass"
    },
    "OutputDataConfig" : {
        "S3OutputLocation" : s3_output_uri,
        "TargetDevice" : "greengrass"
    },
    "StoppingCondition" : {
        "MaxRuntimeInSeconds" : 3600
    },
    "TargetPlatform" : {
        "Os" : "LINUX",
        "Architecture" : "X86_64"
    }
}

# Start the SageMaker Neo compilation job
def trigger_compilation_job():
    try:
        response = sagemaker.create_compilation_job(**compilation_params)
        print (f"Compilation job {compilation_job_name} started successfully."),
        print(json.dumps(response, indent = 4, default = str))

    except Exception as e:
        print(f"Error starting comoliation job: {str(e)}")

        