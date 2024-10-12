# S3 Bucket for Lambda Processed Data
resource "aws_s3_bucket" "lambda_bucket" {
    bucket = "lambda-bucket-talha"
}

# Lifecycle Rule for Lambda Bucket
resource "aws_s3_bucket_lifecycle_configuration" "lambda_config" {
    bucket = aws_s3_bucket.lambda_bucket.id

    rule {
        id = "lambda-archiving"

        filter {
            and {
                prefix = "processed-patient-data/"
                tags = {
                    archive = "true"
                    datalife = "long"
                }
            }
        }
        status = "Enabled"

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

# S3 Bucket for IoT Raw Data
resource "aws_s3_bucket" "iot_bucket" {
    bucket = "iot-bucket-talha"
}

# Lifecycle Rule for IoT Bucket
resource "aws_s3_bucket_lifecycle_configuration" "iot_bucket_config" {
    bucket = aws_s3_bucket.iot_bucket.id

    rule {
        id = "iot-archiving"

        filter {
            and {
                prefix = "raw-patient-data/"
                tags = {
                    archive = "true"
                    datalife = "long"
                }
            }
        }
        status = "Enabled"

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

# S3 Bucket for SageMaker Historical Training Data and Model Artifacts
resource "aws_s3_bucket" "historical_sagemaker_bucket" {
  bucket = "historical-sagemaker-bucket-talha"
}

resource "aws_s3_object" "training_data" {
  bucket = aws_s3_bucket.historical_sagemaker_bucket.bucket
  key = "historical-training-data/mock_health_metrics.csv"
  source = "path/to/mock_health_metrics.csv"
  acl = "private"
}

resource "aws_s3_object" "trained_model_output" {
  bucket = aws_s3_bucket.historical_sagemaker_bucket.bucket
  key = "trained-models/"
  acl = "private"  
}

resource "aws_s3_object" "neo_compilation_output" {
  bucket = aws_s3_bucket.historical_sagemaker_bucket.bucket
  key = "neo-compilation-output/"
  acl = "private"
}

# Lifecycle Rule for Training Data and Model Artifacts
resource "aws_s3_bucket_lifecycle_configuration" "sagemaker_config" {
  bucket = aws_s3_bucket.historical_sagemaker_bucket.id

  rule {
    id = "sagemaker-archiving"

    filter {
      and {
        prefix = "training-data-and-artifacts/"
        tags = {
          archive  = "true"
          datalife = "long"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
}

# S3 Historical Versioning Bucket
resource "aws_s3_bucket" "historical_sagemaker_versioning_bucket" {
  bucket = "historical-sagemaker-versioning-bucket-talha"
}


# Enable S3 Historical Bucket Versioning
resource "aws_s3_bucket_versioning" "historical_sagemaker_versioning" {
  bucket = aws_s3_bucket.historical_sagemaker_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Versioning Lifecycle Rule for Historical Training Data and Model Artifacts
resource "aws_s3_bucket_lifecycle_configuration" "historical_sagemaker_versioning_bucket_config" {
  bucket = aws_s3_bucket.historical_sagemaker_versioning_bucket.id

  rule {
    id = "historical-sagemaker-versioning-bucket-config"

    filter {
      prefix = "versioning-training-data-and-artifacts/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }

    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}

# S3 Bucket to store CodePipeline Artifacts
resource "aws_s3_bucket" "codepipeline_artifacts" {
  bucket = "codepipeline-artifacts-talha"
}

# Lifecycle Rule for CodePipeline
resource "aws_s3_bucket_lifecycle_configuration" "edge_codepipeline_config" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id

  rule {
    id = "codepipeline-archiving"

    filter {
      and {
        prefix = "codepipeline-artifacts/"
        tags = {
          archive  = "true"
          datalife = "long"
        }
      }
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "INTELLIGENT_TIERING"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }
  }
}

# S3 CodePipeline Versioning Bucket
resource "aws_s3_bucket" "codepipeline_artifacts_versioning_bucket" {
  bucket = "codepipeline-artifacts-versioning-bucket-talha"
}


# Enable S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "codepipeline_artifacts_versioning" {
  bucket = aws_s3_bucket.codepipeline_artifacts.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Versioning Lifecycle Rule for CodePipeline
resource "aws_s3_bucket_lifecycle_configuration" "codepipeline_artifacts_versioning_bucket_config" {
  bucket = aws_s3_bucket.codepipeline_artifacts_versioning_bucket.id

  rule {
    id = "codepipeline-artifacts-versioning-bucket-config"

    filter {
      prefix = "versioning-codepipeline-artifacts/"
    }

    noncurrent_version_expiration {
      noncurrent_days = 365
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "INTELLIGENT_TIERING"
    }

    noncurrent_version_transition {
      noncurrent_days = 180
      storage_class   = "GLACIER"
    }

    status = "Enabled"
  }
}

# VPC Gateway Endpoint for S3
resource "aws_vpc_endpoint" "s3_vpc_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = aws_route_table.private_rt[*].id
}
