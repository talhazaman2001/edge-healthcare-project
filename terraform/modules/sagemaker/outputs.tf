output "model_name" {
    description = "Name of the deployed SageMaker model"
    value = aws_sagemaker_model.sagemaker_cloud_model.name
}

output "endpoint_name" {
    description = "Name of the SageMaker endpoint"
    value = aws_sagemaker_endpoint.lstm_endpoint.name
}

output "endpoint_config_name" {
    description = "Name of the endpoint configuration"
    value = aws_sagemaker_endpoint_configuration.lstm_endpoint_config.name
}

output "endpoint_arn" {
    description = "ARN of the SageMaker endpoint"
    value = aws_sagemaker_endpoint.lstm_endpoint.arn
}

output "sagemaker_api_endpoint_id" {
    description = "ID of the SageMaker API VPC endpoint"
    value = aws_vpc_endpoint.sagemaker_api_endpoint.id
}

output "sagemaker_runtime_endpoint_id" {
    description = "ID of the SageMaker runtime VPC endpoint"
    value = aws_vpc_endpoint.sagemaker_runtime_endpoint.id
}