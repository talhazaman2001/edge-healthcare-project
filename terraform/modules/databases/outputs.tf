output "aurora_cluster_endpoint" {
    description = "Endpoint of the Aurora cluster"
    value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_cluster_id" {
    description = "ID of the Aurora cluster"
    value = aws_rds_cluster.aurora_cluster.id
}

output "aurora_security_group_id" {
    description = "ID of the Aurora security group"
    value = aws_security_group.aurora_sg.id
}

output "aurora_cluster_arn" {
    description = "ARN of Aurora Cluster"
    value = aws_rds_cluster.aurora_cluster.arn
}

output "dynamodb_table_name" {
    description = "Name of the DynamoDB table"
    value = aws_dynamodb_table.patient_health_data.name
}

output "dynamodb_table_arn" {
    description = "ARN of the DynamoDB table"
    value = aws_dynamodb_table.patient_health_data.arn
}

output "dynamodb_endpoint_id" {
    description = "ID of the DynamoDB VPC endpoint"
    value = aws_vpc_endpoint.dynamodb_endpoint.id
}