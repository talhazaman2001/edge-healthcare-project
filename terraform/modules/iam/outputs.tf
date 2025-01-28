# Lambda Role ARNs
output "lambda_execution_role_arn" {
    description = "ARN of the main Lambda execution role"
    value       = aws_iam_role.lambda_execution_role.arn
}

output "lambda_sagemaker_training_role_arn" {
    description = "ARN of the Lambda SageMaker training role"
    value       = aws_iam_role.lambda_sagemaker_training_job_role.arn
}

output "lambda_sagemaker_neo_role_arn" {
    description = "ARN of the Lambda SageMaker Neo compilation role"
    value       = aws_iam_role.lambda_sagemaker_neo_compilation_job_role.arn
}

output "lambda_greengrass_role_arn" {
    description = "ARN of the Lambda Greengrass role"
    value       = aws_iam_role.lambda_greengrass_role.arn
}

# Greengrass Role ARNs
output "greengrass_role_arn" {
    description = "ARN of the main Greengrass role"
    value       = aws_iam_role.greengrass_role.arn
}

output "greengrass_role_name" {
    description = "Name of the main Greengrass role"
    value       = aws_iam_role.greengrass_role.name
}

# Policy ARNs
output "lambda_execution_policy_arn" {
    description = "ARN of the Lambda execution policy"
    value       = aws_iam_policy.lambda_execution_policy.arn
}

output "lambda_sagemaker_training_policy_arn" {
    description = "ARN of the Lambda SageMaker training policy"
    value       = aws_iam_policy.lambda_sagemaker_training_job_policy.arn
}

output "lambda_sagemaker_neo_policy_arn" {
    description = "ARN of the Lambda SageMaker Neo compilation policy"
    value       = aws_iam_policy.lambda_sagemaker_neo_compilation_job_policy.arn
}

output "greengrass_base_policy_arn" {
    description = "ARN of the Greengrass base policy"
    value       = aws_iam_policy.greengrass_base_policy.arn
}

output "greengrass_kinesis_policy_arn" {
    description = "ARN of the Greengrass Kinesis policy"
    value       = aws_iam_policy.greengrass_kinesis_policy.arn
}

output "iot_core_role_arn" {
    description = "ARN of Iot Core Role"
    value = aws_iam_role.iot_role.arn
}