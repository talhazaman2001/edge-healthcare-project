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

# Attach required policies
resource "aws_iam_role_policy_attachment" "sagemaker_s3_access" {
    role       = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "sagemaker_cloudwatch_access" {
    role       = aws_iam_role.sagemaker_execution_role.name
    policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
