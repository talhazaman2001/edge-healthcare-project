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

variable "lambda_function_name" {
    description = "Name of the Lambda function to monitor"
    type = string
}

variable "log_retention_days" {
    description = "Number of days to retain CloudWatch logs"
    type = number
    default = 30
}

variable "alert_email" {
    description = "Email address for alert notifications"
    type = string
}
