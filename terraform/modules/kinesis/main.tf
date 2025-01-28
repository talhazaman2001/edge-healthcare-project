# VPC Endpoint for Kinesis
resource "aws_kinesis_stream" "iot_stream" {
    name = "${var.environment}-iot-data-stream"
    shard_count = var.shard_count
    retention_period = var.retention_period

    shard_level_metrics = [
        "IncomingBytes",
        "IncomingRecords",
        "OutgoingBytes",
        "OutgoingRecords"
    ]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-iot-data-stream"
        Terraform = "true"
    }
}

# VPC Endpoint for Kinesis
resource "aws_vpc_endpoint" "kinesis_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.kinesis-streams"
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.endpoint_security_group_id]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-kinesis-endpoint"
        Terraform = "true"
    }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}