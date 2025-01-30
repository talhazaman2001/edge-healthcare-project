# Main Lambda Execution Role
resource "aws_iam_role" "lambda_execution_role" {
    name = "${var.environment}-lambda-execution-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-lambda-execution-role"
        Terraform   = "true"
    }
}

# Lambda Execution Policy
resource "aws_iam_policy" "lambda_execution_policy" {
    name = "${var.environment}-lambda-execution-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem",
                    "dynamodb:GetItem",
                    "dynamodb:DeleteItem",
                    "dynamodb:Scan",
                    "dynamodb:Query"
                ]
                Resource = var.dynamodb_table_arn
            },
            {
                Effect = "Allow"
                Action = [
                    "execute-api:Invoke",
                    "execute-api:ManageConnections"
                ]
                Resource = "${var.api_gateway_execution_arn}/*"
            },
            {
                Effect = "Allow"
                Action = [
                    "rds-data:ExecuteStatement",
                    "rds-data:BatchExecuteStatement",
                    "rds-data:BeginTransaction",
                    "rds-data:CommitTransaction",
                    "rds-data:RollbackTransaction"
                ]
                Resource = var.aurora_cluster_arn
            },
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListBucket"
                ]
                Resource = [
                    var.iot_bucket_arn,
                    "${var.iot_bucket_arn}/*"
                ]    
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-lambda-execution-policy"
        Terraform   = "true"
    }
}

# Policy Attachments for Lambda Execution Role
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attach" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_kinesis_policy" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonKinesisFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_xray_policy" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_sns_policy" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker_policy" {
    role       = aws_iam_role.lambda_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "secrets_access" {
    role       = aws_iam_role.lambda_execution_role
    policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


# SageMaker Training Job Role
resource "aws_iam_role" "lambda_sagemaker_training_job_role" {
    name = "${var.environment}-lambda-training-job-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-sagemaker-training-role"
        Terraform   = "true"
    }
}

resource "aws_iam_policy" "lambda_sagemaker_training_job_policy" {
    name = "${var.environment}-lambda-sagemaker-training-job"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sagemaker:CreateTrainingJob",
                    "sagemaker:DescribeTrainingJob",
                    "s3:GetObject",
                    "s3:PutObject"
                ]
                Resource = [
                    "${var.sagemaker_bucket_arn}/historical-training-data/*",
                    "${var.sagemaker_bucket_arn}/trained-models/*"
                ]
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-sagemaker-training-policy"
        Terraform   = "true"
    }
}

# SageMaker Neo Compilation Role
resource "aws_iam_role" "lambda_sagemaker_neo_compilation_job_role" {
    name = "${var.environment}-lambda-neo-compilation-job-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-sagemaker-neo-role"
        Terraform   = "true"
    }
}

resource "aws_iam_policy" "lambda_sagemaker_neo_compilation_job_policy" {
    name = "${var.environment}-lambda-sagemaker-neo-compilation-job"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sagemaker:CreateTrainingJob",
                    "sagemaker:DescribeTrainingJob",
                    "s3:GetObject",
                    "s3:PutObject"
                ]
                Resource = [
                    "arn:aws:sagemaker:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:compilation-job/*",
                    "${var.sagemaker_bucket_arn}/trained-models/*",
                    "${var.sagemaker_bucket_arn}/neo-compilation-output/*"
                ]
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-sagemaker-neo-policy"
        Terraform   = "true"
    }
}


# Greengrass Lambda Role
resource "aws_iam_role" "lambda_greengrass_role" {
    name = "${var.environment}-lambda-greengrass-role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-greengrass-lambda-role"
        Terraform   = "true"
    }
}

resource "aws_iam_policy" "lambda_greengrass_policy" {
    name = "${var.environment}-lambda-greengrass-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "greengrass:CreateGroup",
                    "greengrass:CreateCoreDefinition",
                    "greengrass:CreateFunctionDefinition",
                    "greengrass:CreateGroupVersion",
                    "greengrass:GetGroupVersion",
                    "iot:DescribeThing",
                    "iot:AttachPolicy",
                    "iot:AttachThingPrincipal"
                ]
                Resource = "*"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-greengrass-lambda-policy"
        Terraform   = "true"
    }
}

# Main Greengrass Role
resource "aws_iam_role" "greengrass_role" {
    name = "${var.environment}-greengrass-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "greengrass.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-greengrass-role"
        Terraform   = "true"
    }
}

resource "aws_iam_policy" "greengrass_base_policy" {
    name = "${var.environment}-greengrass-base-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sagemaker:InvokeEndpoint",
                    "logs:CreateGroup",
                    "logs:CreateLogStream",
                    "logs:PutLogEvents"
                ]
                Resource = [
                    var.greengrass_log_group_arn,
                    var.greengrass_log_stream_arn
                ]
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-greengrass-lambda-policy"
        Terraform   = "true"
    }
}

resource "aws_iam_policy" "greengrass_kinesis_policy" {
    name = "${var.environment}-greengrass-kinesis-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "kinesis:PutRecord",
                    "kinesis:PutRecords"
                ]
                Resource = [var.kinesis_stream_arn]
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-greengrass-kinesis-policy"
        Terraform   = "true"
    }
}

# IAM Role for IoT Thing to interact with IoT Greengrass
resource "aws_iam_role" "iot_role" {
    name = "iot_role"

    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Effect = "Allow"
            Principal = {
                Service = "credentials.iot.amazonaws.com"
            },
            Action = "sts:AssumeRole"
        }]
    })
}
