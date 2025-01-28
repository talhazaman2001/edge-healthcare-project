output "lambda_bucket_id" {
    description = "ID of the Lambda processed data bucket"
    value = aws_s3_bucket.lambda_bucket.id
}

output "iot_bucket_id" {
    description = "ID of the IoT raw data bucket"
    value = aws_s3_bucket.iot_bucket.id
}

output "sagemaker_bucket_id" {
    description = "ID of the SageMaker training data bucket"
    value = aws_s3_bucket.historical_sagemaker_bucket.id
}

output "lambda_bucket_arn" {
    description = "ARN of the Lambda processed data bucket"
    value = aws_s3_bucket.lambda_bucket.arn
}

output "iot_bucket_arn" {
    description = "ARN of the IoT raw data bucket"
    value = aws_s3_bucket.iot_bucket.arn
}

output "sagemaker_bucket_arn" {
    description = "ARN of the SageMaker training data bucket"
    value = aws_s3_bucket.historical_sagemaker_bucket.arn
}

output "s3_endpoint_id" {
    description = "ID of the S3 VPC endpoint"
    value = aws_vpc_endpoint.s3_endpoint.id
}