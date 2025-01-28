output "vpc_id" {
    description = "The ID of the VPC"
    value = aws_vpc.main.id
}

output "public_subnet_ids" {
    description = "List of public subnet IDs"
    value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
    description = "List of private subnet IDs"
    value = aws_subnet.private[*].id
}

output "vpc_endpoint_sg_id" {
    description = "ID of the VPC endpoint security group"
    value = aws_security_group.vpc_endpoints.id
}

output "private_route_table_ids" {
    description = "IDs of Private Route Tables"
    value = aws_route_table.private[*].id
}