variable "environment" {
    description = "Environment name for resource tagging"
    type        = string
}

variable "sagemaker_endpoint_arn" {
    description = "ARN of the SageMaker endpoint"
    type        = string
}

variable "greengrass_role_name" {
    description = "Name of the Greengrass role"
    type        = string
}