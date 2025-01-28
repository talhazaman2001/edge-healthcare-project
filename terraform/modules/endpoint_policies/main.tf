# Greengrass SageMaker Endpoint Policy
resource "aws_iam_policy" "greengrass_endpoint_policy" {
    name = "${var.environment}-greengrass-endpoint-policy"

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Action = [
                    "sagemaker:InvokeEndpoint"
                ]
                Resource = [var.sagemaker_endpoint_arn]
            }
        ]
    })

    tags = {
        Environment = var.environment
        Name        = "${var.environment}-greengrass-endpoint-policy"
        Terraform   = "true"
    }
}

resource "aws_iam_role_policy_attachment" "greengrass_endpoint_policy_attach" {
    role       = var.greengrass_role_name
    policy_arn = aws_iam_policy.greengrass_endpoint_policy.arn
}