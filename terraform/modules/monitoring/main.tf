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

 # SNS Topic for IoT Core Errors
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

# Main ML Monitoring Log Group
resource "aws_cloudwatch_log_group" "ml_monitoring" {
    name = "/aws/healthcare/${var.environment}/ml-monitoring"
    retention_in_days = 30

    tags = {
        Environment = var.environment
        Component = "MLOps"
    }
}

# Model Performance Log Group
resource "aws_cloudwatch_log_group" "model_performance" {
    name = "/aws/healthcare/${var.environment}/model-performance"
    retention_in_days = 30

    tags = {
        Environment = var.environment
        Component = "MLOps"
    }
}

# Data Drift Log Group
resource "aws_cloudwatch_log_group" "data_drift" {
    name = "/aws/healthcare/${var.environment}/data-drift"
    retention_in_days = 30

    tags = {
        Environment = var.environment
        Component = "MLOps"
    }
}

# Log Metric Filter for Model Accuracy
resource "aws_cloudwatch_log_metric_filter" "model_accuracy" {
    name = "${var.environment}-model-accuracy-filter"
    pattern = "[timestamp, accuracy, version]"
    log_group_name = aws_cloudwatch_log_group.model_performance.name

    metric_transformation {
        name = "ModelAccuracy"
        namespace = "Healthcare/ML"
        value = "$accuracy"
        default_value = 0
    }
}

# Log Metric Filter for Prediction Latency
resource "aws_cloudwatch_log_metric_filter" "prediction_latency" {
    name = "${var.environment}-prediction-latency-filter"
    pattern = "[timestamp, accuracy, version]"
    log_group_name = aws_cloudwatch_log_group.model_performance.name

    metric_transformation {
        name = "PredictionLatency"
        namespace = "Healthcare/ML"
        value = "$latency"
        default_value = 0
    }
}

# Model Accuracy Alarm
resource "aws_cloudwatch_metric_alarm" "model_accuracy" {
    alarm_name = "${var.environment}-model-accuracy"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = "2"
    metric_name = "ModelAccuracy"
    namespace = "Healthcare/ML"
    period = "300"
    statistic = "Average"
    threshold = var.accuracy_threshold
    alarm_description = "Model accuracy below threshold"
    alarm_actions = [aws_sns_topic.model_alerts.arn]

    tags = {
        Environment = var.environment
        Component = "MLOps"
    }

    dimensions = {
      LogGroupName = aws_cloudwatch_log_group.model_performance.name
    }
}

# EventBridge Rule to capture CloudWatch Alarm state changes
resource "aws_cloudwatch_event_rule" "model_alarm_rule" {
    name = "${var.environment}-model-alarm-rule"
    description = "Capture CloudWatch alarm state changes for model monitoring"

    event_pattern = jsonencode({
        source = ["aws.cloudwatch"]
        detail-type = ["CloudWatch Alarm State Change"]
        detail = {
            alarmName = [
                aws_cloudwatch_metric_alarm.model_accuracy.alarm_name,
                aws_cloudwatch_metric_alarm.prediction_latency.alarm_name,
                aws_cloudwatch_metric_alarm.data_drift.alarm_name
            ]
        }
    })

    tags = {
        Environment = var.environment 
        Name = "${var.environment}-model-alarm-rule"
        Terraform = "true"
    }
}

# EventBridge target to invoke Lambda
resource "aws_cloudwatch_event_target" "lambda_target" {
    rule = aws_cloudwatch_event_rule.model_alarm_rule.name 
    target_id = "ModelAlarmResponse"
    arn = var.model_alarm_response_lambda_arn
}

# CloudWatch Dashboard for Model Monitoring
resource "aws_cloudwatch_dashboard" "model_monitoring" {
    dashboard_name = "${var.environment}-model-monitoring"

    dashboard_body = jsonencode({
        widgets = [
            {
                type = "metric"
                width = 12
                height = 6
                properties = {
                    metrics = [
                        ["Healthcare/ML", "ModelAccuracy", "ModelVersion", "current"],
                        ["Healthcare/ML", "ModelAccuracy", "ModelVersion", "baseline"]
                    ]
                    period = 300
                    stat = "Average"
                    region = data.aws_region.current.name
                    title = "Model Accuracy Over Time"
                }
            },
            {
                type = "metric"
                width = 12
                height = 6
                properties = {
                    metrics = [
                        ["Healthcare/ML", "PredictionLatency", "ModelVersion", "current"]
                    ]
                    period = 60
                    stat = "Average"
                    region = data.aws_region.current.name
                    title = "Prediction Latency"
                }
            },
            {
                type = "metric"
                width = 12
                height = 6
                properties = {
                    metrics = [
                        ["Healthcare/ML", "DataDrift", "ModelVersion", "current"]
                    ]
                    period = 3600
                    stat = "Average"
                    region = data.aws_region.current.name
                    title = "Data Drift Detection"
                }
            }
        ]
    })
}

# SNS Topic for Model Alerts
resource "aws_sns_topic" "model_alerts" {
    name = "${var.environment}-iot-core-error-alerts"

    tags = {
        Environment = var.environment
        Name = "${var.environment}-model-alerts"
        Terraform = "true"
    }
}

resource "aws_sns_topic_subscription" "model_alerts_email" {
    topic_arn = aws_sns_topic.model_alerts.arn
    protocol = "email"
    endpoint= var.alert_email
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