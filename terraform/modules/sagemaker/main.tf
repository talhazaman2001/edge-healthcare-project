# Deploy the Model to the Cloud (SageMaker Endpoint)
resource "aws_sagemaker_model" "sagemaker_cloud_model" {
    name = "${var.environment}-lstm-model"
    execution_role_arn = var.sagemaker_execution_role_arn

    primary_container {
      image = "764974769150.dkr.ecr.eu-west-2.amazonaws.com/sagemaker-xgboost:1.7-1"
      model_data_url = "s3://${var.model_bucket_name}/trained-models/model.tar.gz"
    }

    depends_on = [ aws_s3_object.initial_model ]
}

# Create dummy model content
resource "aws_s3_object" "initial_model" {
    bucket = var.model_bucket_name
    key = "trained-models/model.tar.gz"
    source = "${path.module}/models/model.tar.gz"
}

resource "aws_sagemaker_endpoint_configuration" "lstm_endpoint_config" {
    name = "${var.environment}-lstm-endpoint-config"

    production_variants {
      variant_name = "variant1"
      model_name = aws_sagemaker_model.sagemaker_cloud_model.name
      initial_instance_count = var.instance_count
      instance_type = var.instance_type
    }
}

resource "aws_sagemaker_endpoint" "lstm_endpoint" {
    name = "${var.environment}-lstm-endpoint"
    endpoint_config_name = aws_sagemaker_endpoint_configuration.lstm_endpoint_config.name
}

# SageMaker API VPC Interface Endpoint for training job
resource "aws_vpc_endpoint" "sagemaker_api_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.eu-west-2.sagemaker.api"  
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.endpoint_security_group_id]
}

# SageMaker Runtime VPC Interface Endpoint for real-time inference
resource "aws_vpc_endpoint" "sagemaker_runtime_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.eu-west-2.sagemaker.runtime" 
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.endpoint_security_group_id]
}


