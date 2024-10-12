# Security Group for Aurora
resource "aws_security_group" "aurora_sg" {
  name        = "aurora_security_group"
  description = "Allow access to Aurora"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allows internal VPC access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aurora-sg"
  }
}

# Aurora Subnet Group
resource "aws_db_subnet_group" "iot_data_group" {
    name = "edge-healthcare-subnet-group"
    subnet_ids = aws_subnet.private_subnets[*].id

    tags = {
        Name = "Edge Healthcare Aurora Subnet Group"
    }
}

# Aurora RDS Cluster
resource "aws_rds_cluster" "iot_data_cluster" {
    cluster_identifier = "auror-cluster"
    engine = "aurora-mysql"
    engine_version = "8.0"
    master_username = "admin"
    master_password = "password"
    backup_retention_period = 7
    preferred_backup_window = "07:00-09:00"
    database_name = "hftdb"
    iam_database_authentication_enabled = true 

    db_subnet_group_name = aws_db_subnet_group.iot_data_group.name

    vpc_security_group_ids = [aws_security_group.aurora_sg.id]
}

# Define Aurora DB Instances
resource "aws_rds_cluster_instance" "aurora_instance" {
    count = 2
    identifier = "aurora-instance-${count.index}"
    cluster_identifier = aws_rds_cluster.iot_data_cluster.id
    instance_class = "db.r5.large"
    engine = aws_rds_cluster.aurora_cluster.engine
}


# DynamoDb Table for Real-Time Patient Health Data
resource "aws_dynamodb_table" "iot_data_table" {
    name = "PatientHealthData"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "PatientID"
    range_key = "Timestamp"

    attribute {
      name = "PatientID"
      type = "S"
    }

    attribute {
      name = "Timestamp"
      type = "N"
    }

    attribute {
      name = "HeartRate"
      type = "N"
    }

    attribute {
      name = "BloodPresure"
      type = "S"
    }

    attribute {
      name = "SpO2"
      type = "N"
    }

    attribute {
      name = "RespiratoryRate"
      type = "N"
    }

    attribute {
      name = "CriticalAlert"
      type = "S"
    }

    local_secondary_index { # For querying by Metric Type
      name = "MetricTypeIndex"
      projection_type = "ALL"
      range_key = "MetricType"
    }

    attribute {
      name = "MetricType"
      type = "S"
    }

    global_secondary_index { # For querying patient data across metrics
      name = "PatientMetricIndex"
      hash_key = "PatientID"
      range_key = "MetricType"
      projection_type = "ALL"
    }

    tags = {
        Name = "PatientHealthData"
    }
}

# DynamoDB VPC Gateway Endpoint
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.dynamodb"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private_rt[*].id
}