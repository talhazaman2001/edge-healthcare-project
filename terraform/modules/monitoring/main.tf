# Lambda Monitoring
resource "aws_cloudwatch_log_group" "lambda_logs" {
    name = "/aws/lambda/${var.lambda_function_name}"
    retention_in_days = var.log_retention_days

    tags = {
        Environment = var.environment
        Name = "${var.environment}-lambda-logs"
        Terraform = "true"
    }
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
    alarm_name = "${var.environment}-lambda-error-alarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    metric_name = "Errors"
    namespace = "AWS/Lambda"
    period = 300
    statistic = "Sum"
    threshold= 1
    alarm_description = "Alarm when Lambda Function has errors"
    alarm_actions = [aws_sns_topic.lambda_errors.arn]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-lambda-error-alarm"
        Terraform = "true"
    }
}

resource "aws_sns_topic" "lambda_errors" {
    name = "${var.environment}-lambda-error-alerts"

    tags = {
        Environment = var.environment
        Name = "${var.environment}-lambda-error-alerts"
        Terraform = "true"
    }
}

resource "aws_sns_topic_subscription" "lambda_errors_email" {
    topic_arn = aws_sns_topic.lambda_errors.arn
    protocol = "email"
    endpoint = var.alert_email
}

# IoT Core Monitoring
resource "aws_cloudwatch_log_group" "iot_core_logs" {
    name = "/aws/iot"
    retention_in_days = var.log_retention_days

    tags = {
        Environment = var.environment
        Name = "${var.environment}-iot-core-logs"
        Terraform = "true"
    }
}

resource "aws_cloudwatch_metric_alarm" "iot_core_errors" {
    alarm_name = "${var.environment}-iot-core-error-alarm"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 1
    metric_name = "NumberOfMessages"
    namespace = "AWS/IoT"
    period = 300
    statistic = "Sum"
    threshold = 1
    alarm_description = "Alarm when IoT Devices stop sending messages"
    alarm_actions = [aws_sns_topic.iot_core_errors.arn]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-iot-core-error-alarm"
        Terraform = "true"
    }
}

resource "aws_sns_topic" "iot_core_errors" {
    name = "${var.environment}-iot-core-error-alerts"

    tags = {
        Environment = var.environment
        Name = "${var.environment}-iot-core-error-alerts"
        Terraform = "true"
    }
}

resource "aws_sns_topic_subscription" "iot_core_errors_email" {
    topic_arn = aws_sns_topic.iot_core_errors.arn
    protocol = "email"
    endpoint= var.alert_email
}

# Greengrass Monitoring
resource "aws_cloudwatch_log_group" "greengrass_logs" {
    name = "/aws/greengrass"
    retention_in_days = var.log_retention_days

    tags = {
        Environment = var.environment
        Name = "${var.environment}-greengrass-logs"
        Terraform = "true"
    }
}

resource "aws_cloudwatch_log_stream" "greengrass_stream" {
    name = "${var.environment}-greengrass-stream"
    log_group_name = aws_cloudwatch_log_group.greengrass_logs.name
}

# SNS VPC Endpoint
resource "aws_vpc_endpoint" "sns_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.sns"
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.endpoint_security_group_id]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-sns-endpoint"
        Terraform = "true"
    }
}

# Data source for current region
data "aws_region" "current" {}