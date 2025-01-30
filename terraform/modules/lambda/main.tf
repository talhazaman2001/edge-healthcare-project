locals {
    lambda_functions = {
        edge_healthcare = {
            name        = "${var.environment}-edge-healthcare"
            handler     = "app.handler"
            runtime     = "python3.12"
            memory_size = 256
            timeout     = 60
            filename    = "${path.root}/../lambda/Lambda-WebSocket/lambda_websocket.zip"
        },
        greengrass_lstm = {
            name        = "${var.environment}-greengrass-lstm"
            handler     = "app.handler"
            runtime     = "python3.9"
            memory_size = 128
            timeout     = 300
            filename    = "${path.root}/../lambda/Lambda-Greengrass-LSTM/greengrass_lstm.zip"
        },
        sagemaker_training = {
            name        = "${var.environment}-sagemaker-training"
            handler     = "app.handler"
            runtime     = "python3.12"
            memory_size = 256
            timeout     = 300
            filename    = "${path.root}/../lambda/Lambda-SageMaker-Training-Job/lambda_sagemaker.zip"
        },
        sagemaker_neo = {
            name        = "${var.environment}-sagemaker-neo"
            handler     = "app.handler"
            runtime     = "python3.12"
            memory_size = 256
            timeout     = 300
            filename    = "${path.root}/../lambda/Lambda-Neo-Compilation/lambda_sagemaker_neo.zip"
        },
        greengrass_creation = {
            name        = "${var.environment}-greengrass-creation"
            handler     = "app.handler"
            runtime     = "python3.12"
            memory_size = 256
            timeout     = 300
            filename    = "${path.root}/../lambda/Lambda-Greengrass-Creation/greengrass_creation.zip"
        },
        model_alarm_response = {
            name        = "${var.environment}-model-alarm-response"
            handler     = "app.handler"
            runtime     = "python3.12"
            memory_size = 256
            timeout     = 300
            filename    = "${path.root}/../lambda/Lambda-Alarm-Response/alarm_response.zip"
        }
    }
}

# Lambda Functions
resource "aws_lambda_function" "functions" {
    for_each = local.lambda_functions

    function_name = each.value.name
    role = var.lambda_roles[each.key]
    handler = each.value.handler
    runtime = each.value.runtime
    memory_size  = each.value.memory_size
    timeout = each.value.timeout
    filename = each.value.filename
    publish = true

    tags = {
        Environment = var.environment
        Name = each.value.name
        Terraform = "true"
    }
}

# Lambda Aliases
resource "aws_lambda_alias" "aliases" {
    for_each = aws_lambda_function.functions

    name = "live"
    function_name = each.value.function_name
    function_version = each.value.version
}

# Lambda Permissions
resource "aws_lambda_permission" "kinesis_invoke" {
    statement_id  = "AllowKinesisInvocation"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.functions["edge_healthcare"].function_name
    principal = "kinesis.amazonaws.com"
    source_arn = var.kinesis_stream_arn
}

resource "aws_lambda_permission" "sagemaker_invoke" {
    statement_id  = "AllowSageMakerInvoke"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.functions["sagemaker_training"].function_name
    principal = "sagemaker.amazonaws.com"
}

resource "aws_lambda_permission" "neo_invoke" {
    statement_id  = "AllowSageMakerInvokeNeoCompilation"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.functions["sagemaker_neo"].function_name
    principal = "sagemaker.amazonaws.com"
}

resource "aws_lambda_permission" "cloudwatch_invoke" {
    statement_id  = "AllowCloudWatchInvocation"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.functions["model_alarm_response"].function_name
    principal = "events.amazonaws.com"
    source_arn = var.model_alarm_rule_arn
}


# VPC Endpoint
resource "aws_vpc_endpoint" "lambda_endpoint" {
    vpc_id = var.vpc_id
    service_name = "com.amazonaws.${data.aws_region.current.name}.lambda"
    vpc_endpoint_type = "Interface"
    subnet_ids = var.private_subnet_ids
    security_group_ids = [var.endpoint_security_group_id]

    tags = {
        Environment = var.environment
        Name = "${var.environment}-lambda-endpoint"
        Terraform = "true"
    }
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}