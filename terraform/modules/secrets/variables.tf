variable "environment" {
    description = "Environment name for resource tagging"
    type        = string
}

variable "sagemaker_role_arn" {
    type = string
    description = "ARN of SageMaker Execution Role"
}   