variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "api_name" {
    description = "Name of the WebSocket API"
    type = string
    default = "HealthAlertWebSocketAPI"
}

variable "lambda_function_arn" {
    description = "ARN of the Lambda function to integrate with"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC where the endpoint will be created"
    type = string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs for the VPC endpoint"
    type = list(string)
}

variable "endpoint_security_group_id" {
    description = "Security group ID for the VPC endpoint"
    type = string
}
