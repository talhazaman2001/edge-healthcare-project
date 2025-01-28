output "stream_name" {
    description = "Name of the Kinesis stream"
    value = aws_kinesis_stream.iot_stream.name
}

output "stream_arn" {
    description = "ARN of the Kinesis stream"
    value = aws_kinesis_stream.iot_stream.arn
}

output "kinesis_endpoint_id" {
    description = "ID of the Kinesis VPC endpoint"
    value = aws_vpc_endpoint.kinesis_endpoint.id
}

output "kinesis_endpoint_dns" {
    description = "DNS entries of the Kinesis VPC endpoint"
    value = aws_vpc_endpoint.kinesis_endpoint.dns_entry
}