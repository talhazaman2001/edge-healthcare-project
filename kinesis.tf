# Kinesis Stream to receive data from IoT Core
resource "aws_kinesis_stream" "iot_data_stream" {
    name = "iot-data-stream"
    shard_count = 20

    retention_period = 24
    shard_level_metrics = ["IncomingBytes", "IncomingRecords", "OutgoingBytes", "OutgoingRecords"]

    tags = {
        Name = "IoTDataStream"
    }
}

# Kinesis VPC Interface Endpoint
resource "aws_vpc_endpoint" "kinesis_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.kinesis"  
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]  
}
