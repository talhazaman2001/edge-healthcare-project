# Secrets Manager for pipeline
resource "aws_secretsmanager_secret" "secrets" {
    name = "${var.environment}-secrets"
}

resource "aws_secretsmanager_secret_version" "secrets" {
    secret_id = aws_secretsmanager_secret.secrets.id
    secret_string = jsonencode({
        sagemaker_role_arn = var.sagemaker_role_arn
    })
}