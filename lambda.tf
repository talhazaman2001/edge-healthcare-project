# IAM Role for Lambda to interact with API Gateway, Aurora, DynamoDB and S3
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda to interact with API Gateway, Aurora, DynamoDB and S3
resource "aws_iam_policy" "lambda_execution_policy" {
    name = "lambda-execution-policy"

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
                ],
                Resource = "${aws_dynamodb_table.iot_data_table.arn}"
            },
            {
                Effect = "Allow"
                Action = [
                    "execute-api:Invoke",
                    "execute-api:ManageConnections"
                ],
                Resource = "${aws_apigatewayv2_api.websocket_api.execution_arn}/*"
            },
            {
                Effect = "Allow"
                Action = [
                    "rds-data:ExecuteStatement",
                    "rds-data:BatchExecuteStatement",
                    "rds-data:BeginTransaction",
                    "rds-data:CommitTransaction",
                    "rds-data:RollbackTransaction"
                ],
                Resource = "${aws_rds_cluster.iot_data_cluster.arn}"
            },
            {
                Effect = "Allow"
                Action = [
                    "s3:GetObject",
                    "s3:PutObject",
                    "s3:DeleteObject",
                    "s3:ListBucket"
                ],
                Resource = [
                    "${aws_s3_bucket.iot-bucket.arn}",
                    "${aws_s3_bucket.iot_bucket.arn}/*"
                ]    
            }
        ]
    })
}

# Attach Policies to IAM Lambda Execution Role

# API Gateway, DynamoDB, Aurora and S3 Policy
resource "aws_iam_role_policy_attachment" "lambda_execution_policy_attach" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.rn
}

# Kinesis Policy
resource "aws_iam_role_policy_attachment" "lambda_kinesis_policy" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonKinesisFullAccess"
}

# CloudWatch Logs Policy
resource "aws_iam_role_policy_attachment" "lambda_cloudwatch_policy" {
  role = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# X-Ray Policy 
resource "aws_iam_role_policy_attachment" "lambda_xray_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

# SNS Policy
resource "aws_iam_role_policy_attachment" "lambda_sns_policy" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSLambdaSNSPublishPolicy"
}

# Define Lambda Function
resource "aws_lambda_function" "edge_healthcare_lambda" {
  function_name = "edge-healthcare-lambda"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "lambda-websocket.handler"
  runtime = "python3.12"
  timeout = 60
  memory_size = 256
  filename = "${path.module}/lambda_websocket.zip"

  environment {
    variables = {
      SAGEMAKER_ENDPOINT = aws_sagemaker_endpoint.lstm_endpoint.name
    }
  }
}

# Permission for Kinesis to invoke Lambda
resource "aws_lambda_permission" "kinesis_invoke_lambda" {  
  statement_id = "AllowKinesisInvocation"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.edge_healthcare_lambda.function_name
  principal = "kinesis.amazonaws.com"
  source_arn = "${aws_kinesis_stream.iot_data_stream.arn}"
}

# Define Lambda Greengrass Function
resource "aws_lambda_function" "greengrass_lstm_function" {
  function_name = "GreenGrassLSTMFunction"
  role = aws_iam_role.lambda_execution_role.arn
  handler = "greengrass-lstm.handler"
  runtime = "python3.9"
  memory_size = 128
  timeout = 300
  filename = "${path.module}/greengrass_lstm.zip"
}


# IAM Role for Lambda and SageMaker training job
resource "aws_iam_role" "lambda_sagemaker_training_job_role" {
  name = "lambda-training-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda and SageMaker training job
resource "aws_iam_policy" "lambda_sagemaker_training_job_policy" {
  name = "lambda-sagemaker-training-job"

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
        ],
        Resource = [
          "${aws_s3_bucket.historical_sagemaker_bucket/historical-training-data}/*",
          "${aws_s3_bucket.historical_training_bucket/trained-models}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker_training_job_policy_attach" {
  role = aws_iam_role.lambda_sagemaker_training_job_role.name
  policy_arn = aws_iam_policy.lambda_sagemaker_training_job_policy.arn
}

# Define Lambda SageMaker training job
resource "aws_lambda_function" "sagemaker_training_job_function" {
  function_name = "sagemaker-training-job"
  role = aws_iam_role.lambda_sagemaker_training_job_role.arn
  runtime = "python3.12"
  handler = "lambda-sagemaker.handler"
  memory_size = 256
  timeout = 300

  filename = "${path.module}/lambda_sagemaker.zip"
}

# Permission for Lambda to invoke SageMaker 
resource "aws_lambda_permission" "invoke_lambda_sagemaker" {
  statement_id = "AllowSageMakerInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sagemaker_training_job_function.function_name
  principal = "sagemaker.amazonaws.com" 
}

# IAM Role for Lambda and SageMaker Neo Compilation Job
resource "aws_iam_role" "lambda_sagemaker_neo_compilation_job_role" {
  name = "lambda-neo-compilation-job-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda and SageMaker Neo Compilation job
resource "aws_iam_policy" "lambda_sagemaker_neo_compilation_job_policy" {
  name = "lambda-sagemaker-neo-compilation-job"

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
        ],
        Resource = [
          "arn:aws:sagemaker:eu-west-2:463470963000:compilation-job/*",
          "${aws_s3_bucket.historical_training_bucket/trained-models}/*",
          "${aws_s3_buclet.historical_training_bucket/neo-compilation-output}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sagemaker_neo_compilation_job_policy_attach" {
  role = aws_iam_role.lambda_sagemaker_neo_compilation_job_role.name
  policy_arn = aws_iam_policy.lambda_sagemaker_neo_compilation_job_policy.arn
}

# Define Lambda SageMaker Neo Compilation Job
resource "aws_lambda_function" "sagemaker_neo_compilation_job_function" {
  function_name = "sagemaker-neo-compilation-job"
  role = aws_iam_role.lambda_sagemaker_neo_compilation_job_role.arn
  runtime = "python3.12"
  handler = "lambda-sagemaker-neo.handler"
  memory_size = 256
  timeout = 300

  filename = "${path.module}/lambda_sagemaker_neo.zip"
}

# Permission for Lambda to invoke Neo Compilation Job
resource "aws_lambda_permission" "invoke_lambda_neo" {
  statement_id = "AllowSageMakerInvokeNeoCompilation"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sagemaker_neo_compilation_job_function.function_name
  principal = "sagemaker.amazonaws.com" 
}

# IAM Role for Lambda Greengrass Group
resource "aws_iam_role" "lambda_greengrass_role" {
  name = "lambda-greengrass-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# IAM Policy for Lambda to access Greengrass
resource "aws_iam_policy" "lambda_greengrass_policy" {
  name = "lambda-greengrass-policy"

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
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_greengrass_policy_attach" {
  role = aws_iam_role.lambda_greengrass_role.name
  policy_arn = aws_iam_policy.lambda_greengrass_policy.arn
}

# Define the Lambda Function to create Greengrass
resource "aws_lambda_function" "lambda_greengrass_creation_function" {
  function_name = "lambda-greengrass-creation"
  role = aws_iam_role.lambda_greengrass_role.arn
  runtime = "python3.12"
  handler = "greengrass-creation.handler"
  memory_size = 256
  timeout = 300

  filename = "${path.module}/greengrass_creation.zip"
}

# Permission for Lambda to create Greengrass
resource "aws_lambda_permission" "invoke_lambda_greengrass" {
  statement_id = "AllowLambdaInvoke"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_greengrass_function.function_name
  principal = "lambda.amazonaws.com" 
}

# Lambda VPC Interface Endpoint
resource "aws_vpc_endpoint" "lambda_interface_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.lambda"  
  vpc_endpoint_type = "Interface"
  
  subnet_ids = aws_subnet.private_subnets[*].id  
  security_group_ids = [aws_security_group.lambda_endpoint_sg.id] 
}

