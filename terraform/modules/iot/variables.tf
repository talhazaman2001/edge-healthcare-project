variable "environment" {
    description = "Environment name for resource tagging"
    type = string
}

variable "kinesis_stream_name" {
    description = "Name of the Kinesis stream"
    type = string
}

variable "iot_core_role_arn" {
    description = "ARN of the IoT Core IAM role"
    type = string
}