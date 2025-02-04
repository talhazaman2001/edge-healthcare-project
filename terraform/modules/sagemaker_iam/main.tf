# SageMaker Execution Role
resource "aws_iam_role" "sagemaker_execution_role" {
    name = "${var.environment}-sagemaker-execution-role"
    
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    Service = "sagemaker.amazonaws.com"
                }
                Action = "sts:AssumeRole"
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-sagemaker-execution-role"
        Terraform   = "true"
    }
}

# ECR Access
resource "aws_iam_policy" "sagemaker_ecr_access" {
    name = "${var.environment}-sagemaker-ecr-access"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "ecr:*"
                ]
                Resource = [
                    "arn:aws:ecr:eu-west-2:764904185921:repository/sagemaker-xgboost"
                ]
            },
            {
                Effect = "Allow"
                Action = [
                    "ecr:GetAuthorizationToken"
                ]
                Resource = "*"
            }
        ]
    })
}


# Attach required policies
resource "aws_iam_role_policy_attachment" "sagemaker_s3_access" {
    role       = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_cloudwatch_access" {
    role       = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_full_access" {
    role       = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_ecr_access" {
    role       = aws_iam_role.sagemaker_execution_role.name
    policy_arn = aws_iam_policy.sagemaker_ecr_access.arn
}