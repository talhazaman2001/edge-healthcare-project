output "endpoint_policy_arn" {
    description = "ARN of the Greengrass endpoint policy"
    value       = aws_iam_policy.greengrass_endpoint_policy.arn
}