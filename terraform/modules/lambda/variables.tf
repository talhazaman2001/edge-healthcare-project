variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "vpc_id" {
    description = "ID of the VPC"
    type= string
}

variable "private_subnet_ids" {
    description = "List of private subnet IDs"
    type = list(string)
}

variable "endpoint_security_group_id" {
    description = "Security group ID for VPC endpoints"
    type = string
}

variable "kinesis_stream_arn" {
    description = "ARN of the Kinesis stream"
    type = string
}

variable "lambda_roles" {
    description = "Map of Lambda function roles"
    type = map(string)
}

variable "lambda_source_dir" {
    description = "Directory containing Lambda function source code"
    type = string
}
