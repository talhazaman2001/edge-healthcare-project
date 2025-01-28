output "function_arns" {
    description = "Map of Lambda function ARNs"
    value = {
        for k, v in aws_lambda_function.functions : k => v.arn
    }
}

output "function_names" {
    description = "Map of Lambda function names"
    value = {
        for k, v in aws_lambda_function.functions : k => v.function_name
    }
}

output "edge_healthcare_lambda_arn" {
    description = "ARN of the edge healthcare Lambda function"
    value = aws_lambda_function.functions["edge_healthcare"].arn
}

output "vpc_endpoint_id" {
    description = "ID of the Lambda VPC endpoint"
    value = aws_vpc_endpoint.lambda_endpoint.id
}

output "vpc_endpoint_dns_names" {
    description = "DNS entries for the Lambda VPC endpoint"
    value = aws_vpc_endpoint.lambda_endpoint.dns_entry
}