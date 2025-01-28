# Aurora Security Group
resource "aws_security_group" "aurora_sg" {
    name = "${var.environment}-aurora-security-group"
    description = "Security group for Aurora cluster"
    vpc_id= var.vpc_id

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = [var.vpc_cidr]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-aurora-sg"
        Environment = var.environment
        Terraform = "true"
    }
}

# Aurora Subnet Group
resource "aws_db_subnet_group" "aurora_subnet_group" {
    name = "${var.environment}-aurora-subnet-group"
    subnet_ids = var.private_subnet_ids

    tags = {
        Name = "${var.environment}-aurora-subnet-group"
        Environment = var.environment
        Terraform = "true"
    }
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora_cluster" {
    cluster_identifier = "${var.environment}-aurora-cluster"
    engine = "aurora-mysql"
    engine_version = "8.0"
    database_name = var.database_name
    master_username = var.master_username
    master_password = var.master_password
    backup_retention_period = 7
    preferred_backup_window = "07:00-09:00"
    
    iam_database_authentication_enabled = true
    db_subnet_group_name = aws_db_subnet_group.aurora_subnet_group.name
    vpc_security_group_ids = [aws_security_group.aurora_sg.id]

    tags = {
        Name = "${var.environment}-aurora-cluster"
        Environment = var.environment
        Terraform = "true"
    }
}

resource "aws_rds_cluster_instance" "aurora_instances" {
    count = var.instance_count
    identifier = "${var.environment}-aurora-instance-${count.index + 1}"
    cluster_identifier = aws_rds_cluster.aurora_cluster.id
    instance_class = var.instance_class
    engine = aws_rds_cluster.aurora_cluster.engine

    tags = {
        Name = "${var.environment}-aurora-instance-${count.index + 1}"
        Environment = var.environment
        Terraform = "true"
    }
}

# DynamoDB Table
resource "aws_dynamodb_table" "patient_health_data" {
    name = "${var.environment}-patient-health-data"
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
        name = "MetricType"
        type = "S"
    }

    local_secondary_index {
        name = "MetricTypeIndex"
        projection_type = "ALL"
        range_key = "MetricType"
    }

    global_secondary_index {
        name = "PatientMetricIndex"
        hash_key = "PatientID"
        range_key = "MetricType"
        projection_type = "ALL"
    }

    tags = {
        Name = "${var.environment}-patient-health-data"
        Environment = var.environment
        Terraform = "true"
    }
}

# VPC Endpoint for DynamoDB
resource "aws_vpc_endpoint" "dynamodb_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.dynamodb"
    vpc_endpoint_type = "Gateway"
    route_table_ids = var.private_route_table_ids

    tags = {
        Name = "${var.environment}-dynamodb-endpoint"
        Environment = var.environment
        Terraform = "true"
    }
}

# DynamoDB Table for tracking Model Metrics
resource "aws_dynamodb_table" "model_metrics" {
    name = "${var.environment}-model-metrics"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "ModelVersion"
    range_key = "Timestamp"

    attribute {
        name = "ModelVersion"
        type = "S"
    }

    attribute {
        name = "Timestamp"
        type = "N"
    }

    attribute {
        name = "MetricType"
        type = "S"
    }

    # GSI for querying by metric type
    global_secondary_index {
        name = "MetricTypeIndex"
        hash_key = "MetricType"
        range_key = "Timestamp"
        projection_type = "ALL"
    }

    tags = {
        Environment = var.environment
        Name = "${var.environment}-model-metrics"
        Component = "MLOps"
    }
}

# Data source for current region
data "aws_region" "current" {}