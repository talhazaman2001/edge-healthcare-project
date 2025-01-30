output "lambda_log_group_name" {
    description = "Name of the Lambda CloudWatch log group"
    value= aws_cloudwatch_log_group.lambda_logs.name
}

output "iot_core_log_group_name" {
    description = "Name of the IoT Core CloudWatch log group"
    value = aws_cloudwatch_log_group.iot_core_logs.name
}

output "greengrass_log_group_name" {
    description = "Name of the Greengrass CloudWatch log group"
    value = aws_cloudwatch_log_group.greengrass_logs.name
}

output "greengrass_log_group_arn" {
    description = "ARN of the Greengrass CloudWatch log group"
    value = aws_cloudwatch_log_group.greengrass_logs.arn
}

output "greengrass_log_stream_arn" {
    description = "ARN of the Greengrass CloudWatch log stream"
    value = aws_cloudwatch_log_stream.greengrass_stream.arn
}

output "lambda_sns_topic_arn" {
    description = "ARN of the Lambda error SNS topic"
    value = aws_sns_topic.lambda_errors.arn
}

output "iot_core_sns_topic_arn" {
    description = "ARN of the IoT Core error SNS topic"
    value = aws_sns_topic.iot_core_errors.arn
}

output "sns_endpoint_id" {
    description = "ID of the SNS VPC endpoint"
    value = aws_vpc_endpoint.sns_endpoint.id
}

output "sns_endpoint_dns" {
    description = "DNS entries for the SNS VPC endpoint"
    value = aws_vpc_endpoint.sns_endpoint.dns_entry
}

output "model_alarm_rule_arn" {
    description = "Cloudwatch Alarm Rule for Model response"
    value = aws_cloudwatch_event_rule.model_alarm_rule.arn
}