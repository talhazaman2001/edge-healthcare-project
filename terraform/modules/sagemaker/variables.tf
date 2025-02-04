variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs"
    type = list(string)
}

variable "endpoint_security_group_id" {
    description = "Security group ID for VPC endpoints"
    type = string
}

variable "model_bucket_name" {
    description = "Name of the S3 bucket containing model artifacts"
    type = string
}

variable "model_image_uri" {
    description = "URI of the model image in ECR"
    type = string
    default = "764974769150.dkr.ecr.eu-west-2.amazonaws.com/sagemaker-xgboost:1.7-1"
}

variable "instance_type" {
    description = "SageMaker instance type for endpoint"
    type = string
    default = "ml.m5.large"
}

variable "instance_count" {
    description = "Number of instances for the endpoint"
    type = number
    default = 1
}

variable "sagemaker_execution_role_arn" {
    description = "SageMaker Execution Role ARN"
    type = string
}

variable "sagemaker_bucket_id" {
    description = "SageMaker Bucket ID"
    type = string
}
