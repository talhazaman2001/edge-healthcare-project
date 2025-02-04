# Lambda Data Bucket
resource "aws_s3_bucket" "lambda_bucket" {
    bucket = "lambda-bucket-talha"
    
    tags = {
        Environment = var.environment
        Name = "lambda-processed-data"
        Terraform = "true"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "lambda_config" {
    bucket = aws_s3_bucket.lambda_bucket.id

    rule {
        id = "lambda-archiving"
        status = "Enabled"

        filter {
            and {
                prefix = "processed-patient-data/"
                tags = {
                    archive = "true"
                    datalife = "long"
                }
            }
        }

        transition {
            days = 30
            storage_class = "INTELLIGENT_TIERING"
        }

        transition {
            days = 180
            storage_class = "GLACIER"
        }
    }
}

# IoT Data Bucket
resource "aws_s3_bucket" "iot_bucket" {
    bucket = "iot-bucket-talha"
    
    tags = {
        Environment = var.environment
        Name = "iot-raw-data"
        Terraform = "true"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "iot_bucket_config" {
    bucket = aws_s3_bucket.iot_bucket.id

    rule {
        id = "iot-archiving"
        status = "Enabled"

        filter {
            and {
                prefix = "raw-patient-data/"
                tags = {
                    archive = "true"
                    datalife = "long"
                }
            }
        }

        transition {
            days = 30
            storage_class = "INTELLIGENT_TIERING"
        }

        transition {
            days = 180
            storage_class = "GLACIER"
        }
    }
}

# SageMaker Bucket
resource "aws_s3_bucket" "historical_sagemaker_bucket" {
    bucket = "historical-sagemaker-bucket-talha"
    
    tags = {
        Environment = var.environment
        Name = "sagemaker-training-data"
        Terraform = "true"
    }
}

resource "aws_s3_bucket_versioning" "historical_sagemaker_versioning" {
    bucket = aws_s3_bucket.historical_sagemaker_bucket.id
    
    versioning_configuration {
        status = "Enabled"
    }
}

resource "aws_s3_bucket_lifecycle_configuration" "sagemaker_config" {
    bucket = aws_s3_bucket.historical_sagemaker_bucket.id

    rule {
        id = "sagemaker-archiving"
        status = "Enabled"

        filter {
            and {
                prefix = "training-data-and-artifacts/"
                tags = {
                    archive = "true"
                    datalife = "long"
                }
            }
        }

        transition {
            days = 30
            storage_class = "INTELLIGENT_TIERING"
        }

        transition {
            days = 180
            storage_class = "GLACIER"
        }
    }
}

# VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.s3"
    vpc_endpoint_type = "Gateway"
    route_table_ids = var.private_route_table_ids

    tags = {
        Environment = var.environment
        Name = "${var.environment}-s3-endpoint"
        Terraform = "true"
    }
}

# Data source for current region
data "aws_region" "current" {}