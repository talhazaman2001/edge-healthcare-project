# SageMaker Execution Role
resource "aws_iam_role" "sagemaker_execution_role" {
    name = "sagemaker-execution-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "sagemaker.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

# IAM Policies to attach to SageMaker Execution Role
resource "aws_iam_role_policy_attachment" "sagemaker_s3_access" {
    role = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_cloudwatch_access" {
    role = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_aurora_access" {
    role = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_dynamodb_access" {
    role = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

# IAM Role to allow Greengrass Lambda function to access SageMaker Endpoint
resource "aws_iam_role" "greengrass_role" {
    name = "greengrass-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "greengrass.amazonaws.com"
                },
                Action = "sts:AssumeRole"
            }
        ]
    })
}

resource "aws_iam_policy" "greengrass_lambda_policy" {
    name = "GreengrassLambdaPolicy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sagemaker:InvokeEndpoint",
                    "logs:CreateGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = [
                    "arn:aws:sagemaker:eu-west-2${data.aws_caller_identity.current.account_id}:endpoint/{aws_sagemaker_endpoint.lstm_endpoint.name}",
                    "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.greengrass_log_group.name}",
                    "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-stream:${aws_cloudwatch_log_stream.greengrass_log_stream.name}",
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "greengrass_lambda_policy_attach" {
    role = aws_iam_role.greengrass_role.name
    policy_arn = aws_iam_policy.greengrass_lambda_policy.arn
}

# Retrieve Current Account ID
data "aws_caller_identity" "current" {}


# IAM Policy to allow Greengrass to stream data through Kinesis to Lambda
resource "aws_iam_policy" "greengrass_kinesis_policy" {
    name = "GreengrassKinesisPolicy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "kinesis:PutRecord",
                    "kinesis:PutRecords"
                ]
                Resource = [
                    "${aws_kinesis_stream.iot_data_stream.arn}"
                ]
            }
        ]
    })
}

resource "aws_iam_role_policy_attachment" "greengrass_kinesis_policy_attach" {
    role = aws_iam_role.greengrass_role.name
    policy_arn = aws_iam_policy.greengrass_kinesis_policy.arn
}

# Deploy the Model to the Cloud (SageMaker Endpoint)
resource "aws_sagemaker_model" "sagemaker_cloud_model" {
    name = "lstm-cloud-model"
    execution_role_arn = aws_iam_role.sagemaker_execution_role.arn

    primary_container {
      image = "763104351884.dkr.ecr.eu-west-2.amazonaws.com/tensorflow-training:2.3.0-gpu-py37-cu110-ubuntu18.04"
      model_data_url = "${aws_s3_bucket.historical_sagemaker_bucket.bucket}"
    }
}

resource "aws_sagemaker_endpoint_configuration" "lstm_endpoint_config" {
    name = "lstm-endpoint-config"

    production_variants {
      variant_name = "variant1"
      model_name = aws_sagemaker_model.sagemaker_cloud_model.name
      initial_instance_count = 1
      instance_type = "ml.p2.xlarge"
    }
}

resource "aws_sagemaker_endpoint" "lstm_endpoint" {
    endpoint_config_name = aws_sagemaker_endpoint_configuration.lstm_endpoint_config.name
}

# SageMaker API VPC Interface Endpoint for training job
resource "aws_vpc_endpoint" "sagemaker_api_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.sagemaker.api"  
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]  
}

# SageMaker Runtime VPC Interface Endpoint for real-time inference
resource "aws_vpc_endpoint" "sagemaker_runtime_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.sagemaker.runtime" 
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]
}


