variable "environment" {
    description = "Environment name for resource tagging"
    type        = string
}

variable "dynamodb_table_arn" {
    description = "ARN of the DynamoDB table"
    type        = string
}

variable "aurora_cluster_arn" {
    description = "ARN of the Aurora cluster"
    type        = string
}

variable "api_gateway_execution_arn" {
    description = "ARN of API Gateway Execution"
    type = string
}

variable "iot_bucket_arn" {
    description = "ARN of the IoT S3 bucket"
    type        = string
}

variable "sagemaker_bucket_arn" {
    description = "ARN of the SageMaker S3 bucket"
    type        = string
}

variable "kinesis_stream_arn" {
    description = "ARN of the Kinesis stream"
    type        = string
}

variable "greengrass_log_group_arn" {
    description = "ARN of the Greengrass CloudWatch log group"
    type        = string
}

variable "greengrass_log_stream_arn" {
    description = "ARN of the Greengrass CloudWatch log stream"
    type        = string
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}