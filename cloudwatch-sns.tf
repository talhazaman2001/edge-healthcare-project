# Lambda CloudWatch Logs 
resource "aws_cloudwatch_log_group" "lambda_log_group" {
    name = "/aws/lambda/${aws_lambda_function.edge_healthcare_lambda.function_name}"
    retention_in_days = 30
}

# Lambda CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
    alarm_name = "LambdaErrorAlarm"
    comparison_operator = "GreaterThanThreshold"
    evaluation_periods = 1
    metric_name = "Errors"
    namespace = "AWS/Lambda"
    period = 300
    statistic = "Sum"
    threshold = 1
    alarm_description = "Alarm when Lambda Function has errors"
    alarm_actions = [aws_sns_topic.lambda_error_topic.arn]
}

# Lambda SNS topic
resource "aws_sns_topic" "lambda_error_topic" {
    name = "LambdaErrorAlerts"
}

resource "aws_sns_topic_subscription" "lambda_error_email" {
    topic_arn = aws_sns_topic.lambda_error_topic.arn
    protocol = "email"
    endpoint = "mtalhazamanb@gmail.com"
}

# IoT Core CloudWatch Logs
resource "aws_cloudwatch_log_group" "iot_core_log_group" {
    name = "/aws/iot/"
    retention_in_days = 30
}

# IoT Core CloudWatch Alarm
resource "aws_cloudwatch_metric_alarm" "iot_core_error_alarm" {
    alarm_name = "IoTCoreErrorAlarm"
    comparison_operator = "LessThanThreshold"
    evaluation_periods = 1
    metric_name = "NumberOfMessages"
    namespace = "AWS/IoT"
    period = 300
    statistic = "Sum"
    threshold = 1
    alarm_description = "Alarm when IoT Devices stop sending messages"
    alarm_actions = [aws_sns_topic.iot_core_error_topic.arn]
}

# IoT Core SNS topic
resource "aws_sns_topic" "iot_core_error_topic" {
    name = "LambdaErrorAlerts"
}

resource "aws_sns_topic_subscription" "iot_core_error_email" {
    topic_arn = aws_sns_topic.iot_core_error_topic.arn
    protocol = "email"
    endpoint = "mtalhazamanb@gmail.com"
}

# Greengrass Log Group
resource "aws_cloudwatch_log_group" "greengrass_log_group" {
    name = "/aws/greengrass/"
    retention_in_days = 30
}

# Greengrass Log Stream
resource "aws_cloudwatch_log_stream" "greengrass_log_stream" {
    name = "GreengrassLogStream"
    log_group_name = aws_cloudwatch_log_group.greengrass_log_group.name
}

# SNS VPC Interface Endpoint
resource "aws_vpc_endpoint" "sns_endpoint" {
  vpc_id = aws_vpc.main_vpc.id
  service_name = "com.amazonaws.eu-west-2.sns"  
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.private_subnets[*].id
  security_group_ids = [aws_security_group.endpoint_sg.id]  
}